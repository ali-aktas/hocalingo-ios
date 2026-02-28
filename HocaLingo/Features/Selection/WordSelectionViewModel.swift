//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  Location: Features/Selection/WordSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Word Selection ViewModel
class WordSelectionViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var currentWord: Word?
    @Published var nextWord: Word?
    @Published var selectedCount: Int = 0
    @Published var isLoading: Bool = true
    @Published var isProcessingSwipe: Bool = false
    @Published var isCompleted: Bool = false
    @Published var errorMessage: String?

    @Published var remainingSelections: Int? = nil
    @Published var showSelectionWarning: Bool = false
    @Published var selectionLimitReached: Bool = false
    @Published var isPremium: Bool = false

    // Session progress — reset to zero every time the screen opens.
    // This keeps the denominator (sessionTotalCards) and numerator (sessionProcessed)
    // in the same unit, preventing the "62/32" overflow that happened when
    // processedWords was restored from all-time persisted counts.
    @Published private(set) var sessionTotalCards: Int = 0
    @Published private(set) var sessionProcessed: Int = 0

    /// Cards remaining in the current session (used by progress bar label).
    var cardsRemaining: Int { max(0, sessionTotalCards - sessionProcessed) }

    /// Progress fraction [0...1] for the progress bar fill.
    /// Bar shrinks from full → empty as cards are processed.
    var sessionProgress: Double {
        guard sessionTotalCards > 0 else { return 0 }
        return Double(cardsRemaining) / Double(sessionTotalCards)
    }

    /// Single-integer card identity token.
    /// Incremented on every forward transition so WordSelectionView can drive
    /// SwipeableCardView's .id() from ONE place.
    @Published private(set) var cardTransitionId: Int = 0

    var canUndo: Bool { !undoStack.isEmpty }

    // MARK: - Private Properties
    private let packageId: String
    private var currentWordIndex: Int = 0
    private var remainingWords: [Word] = []
    private var allWords: [Word] = []
    private var selectedWordIds: Set<Int> = []
    private var hiddenWordIds: Set<Int> = []
    private var undoStack: [UndoAction] = []

    private let soundManager = SoundManager.shared
    private let jsonLoader = JSONLoader()
    private let userDefaults = UserDefaultsManager.shared
    private let selectionLimitManager = DailySelectionLimitManager.shared

    /// Guard window matches SwipeableCardView animationDuration (0.28s) + small margin.
    private let swipeGuardDuration: Double = 0.32
    private let maxUndoStackSize = 5

    // MARK: - Init
    init(packageId: String) {
        self.packageId = packageId
        self.isPremium = selectionLimitManager.isPremium
        loadWords()
        updateSelectionLimit()
    }

    // MARK: - Load Words
    func loadWords() {
        isLoading = true
        errorMessage = nil

        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            allWords = vocabPackage.words

            let selections = userDefaults.getWordSelections(packageId: packageId)
            selectedWordIds = Set(selections.selected)
            hiddenWordIds = Set(selections.hidden)

            let unseenWords = allWords.filter {
                !selectedWordIds.contains($0.id) && !hiddenWordIds.contains($0.id)
            }

            remainingWords = unseenWords.shuffled()
            selectedCount = selectedWordIds.count

            // Session counters — always start from zero so the progress bar
            // denominator equals exactly the cards available in this session.
            sessionTotalCards = unseenWords.count
            sessionProcessed = 0

            if unseenWords.isEmpty {
                isCompleted = true
                isLoading = false
                return
            }

            updateCurrentWord()
            isLoading = false

            #if DEBUG
            print("📚 Loaded \(allWords.count) total | \(unseenWords.count) unseen this session")
            #endif

        } catch {
            errorMessage = "Failed to load words: \(error.localizedDescription)"
            isLoading = false
            #if DEBUG
            print("❌ Load error: \(error)")
            #endif
        }
    }

    // MARK: - Swipe Left (Skip)
    func swipeLeft() {
        guard let word = currentWord, !isProcessingSwipe else { return }

        isProcessingSwipe = true
        soundManager.playSwipeLeft()

        pushUndo(UndoAction(wordId: word.id, action: .hide))

        hiddenWordIds.insert(word.id)
        sessionProcessed += 1

        saveSelections()
        advanceCard()
        scheduleProcessingRelease()

        #if DEBUG
        print("⬅️ Skipped: \(word.english)")
        #endif
    }

    // MARK: - Swipe Right (Learn)
    func swipeRight() {
        guard let word = currentWord, !isProcessingSwipe else { return }

        guard selectionLimitManager.canSelect() else {
            selectionLimitReached = true
            return
        }

        isProcessingSwipe = true

        let _ = selectionLimitManager.recordSelection()
        updateSelectionLimit()
        soundManager.playSwipeRight()

        pushUndo(UndoAction(wordId: word.id, action: .select))

        selectedWordIds.insert(word.id)
        selectedCount += 1
        sessionProcessed += 1

        saveSelections()
        advanceCard()
        scheduleProcessingRelease()

        NotificationCenter.default.post(name: NSNotification.Name("WordsChanged"), object: nil)

        #if DEBUG
        print("➡️ Selected: \(word.english)")
        #endif
    }

    // MARK: - Undo
    func undoLastAction() {
        guard let lastAction = undoStack.popLast() else { return }

        if lastAction.action == .select {
            selectionLimitManager.undoSelection()
            updateSelectionLimit()
            if selectionLimitReached { selectionLimitReached = false }
        }

        guard let word = allWords.first(where: { $0.id == lastAction.wordId }) else { return }

        soundManager.playClickSound()

        switch lastAction.action {
        case .select:
            selectedWordIds.remove(lastAction.wordId)
            selectedCount -= 1
            sessionProcessed = max(0, sessionProcessed - 1)
            #if DEBUG
            print("↩️ Undone select: \(word.english)")
            #endif
        case .hide:
            hiddenWordIds.remove(lastAction.wordId)
            sessionProcessed = max(0, sessionProcessed - 1)
            #if DEBUG
            print("↩️ Undone skip: \(word.english)")
            #endif
        }

        currentWordIndex = max(0, currentWordIndex - 1)
        updateCurrentWord()
        cardTransitionId += 1
        saveSelections()
    }

    // MARK: - Navigate to Study
    func navigateToStudy() {
        saveSelections()
    }

    // MARK: - Private Helpers

    private func updateCurrentWord() {
        if currentWordIndex < remainingWords.count {
            currentWord = remainingWords[currentWordIndex]
            nextWord = currentWordIndex + 1 < remainingWords.count
                ? remainingWords[currentWordIndex + 1]
                : nil
        } else {
            currentWord = nil
            nextWord = nil
            isCompleted = true
        }
    }

    private func advanceCard() {
        currentWordIndex += 1
        updateCurrentWord()
        cardTransitionId += 1
    }

    private func pushUndo(_ action: UndoAction) {
        undoStack.append(action)
        if undoStack.count > maxUndoStackSize { undoStack.removeFirst() }
    }

    private func scheduleProcessingRelease() {
        DispatchQueue.main.asyncAfter(deadline: .now() + swipeGuardDuration) {
            self.isProcessingSwipe = false
        }
    }

    private func updateSelectionLimit() {
        if selectionLimitManager.isPremium {
            remainingSelections = nil
            showSelectionWarning = false
        } else {
            remainingSelections = selectionLimitManager.getRemainingSelections()
            showSelectionWarning = selectionLimitManager.shouldShowWarning()
        }
    }

    private func saveSelections() {
        userDefaults.saveWordSelections(
            packageId: packageId,
            selected: Array(selectedWordIds),
            hidden: Array(hiddenWordIds)
        )
        userDefaults.syncGlobalSelectedWords()
    }
}

// MARK: - Undo Action (Private)
private struct UndoAction {
    let wordId: Int
    let action: ActionType
    enum ActionType { case select, hide }
}
