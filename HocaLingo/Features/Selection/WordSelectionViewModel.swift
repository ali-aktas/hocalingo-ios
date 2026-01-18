//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  ✅ FINAL: Learn is limited, Skip is free
//  Location: HocaLingo/Features/Selection/WordSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Word Selection ViewModel
class WordSelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var words: [Word] = []
    @Published var currentWord: Word?
    @Published var nextWord: Word?
    @Published var selectedCount: Int = 0
    @Published var hiddenCount: Int = 0
    @Published var processedWords: Int = 0
    @Published var isLoading: Bool = true
    @Published var isProcessingSwipe: Bool = false
    @Published var isCompleted: Bool = false
    @Published var errorMessage: String?
    
    @Published var remainingSelections: Int? = nil
    @Published var showSelectionWarning: Bool = false
    @Published var selectionLimitReached: Bool = false
    @Published var isPremium: Bool = false
    
    // MARK: - Private Properties
    private let packageId: String
    private var currentWordIndex: Int = 0
    private var remainingWords: [Word] = []
    private var selectedWordIds: Set<Int> = []
    private var hiddenWordIds: Set<Int> = []
    private var undoStack: [UndoAction] = []
    private let soundManager = SoundManager.shared
    private let jsonLoader = JSONLoader()
    private let userDefaults = UserDefaultsManager.shared
    private let selectionLimitManager = DailySelectionLimitManager.shared
    
    private let maxUndoStackSize = 5
    
    var totalWordsCount: Int {
        remainingWords.count
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty
    }
    
    init(packageId: String) {
        self.packageId = packageId
        self.isPremium = selectionLimitManager.isPremium
        loadWords()
        updateSelectionLimit()
    }
    
    func loadWords() {
        isLoading = true
        errorMessage = nil
        
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            let allWords = vocabPackage.words
            
            let selections = userDefaults.getWordSelections(packageId: packageId)
            selectedWordIds = Set(selections.selected)
            hiddenWordIds = Set(selections.hidden)
            
            let unseenWords = allWords.filter { word in
                !selectedWordIds.contains(word.id) && !hiddenWordIds.contains(word.id)
            }
            
            self.words = allWords
            self.remainingWords = unseenWords
            self.selectedCount = selectedWordIds.count
            self.hiddenCount = hiddenWordIds.count
            
            if unseenWords.isEmpty {
                self.isCompleted = true
                self.isLoading = false
                print("✅ Package completed")
                return
            }
            
            updateCurrentWord()
            isLoading = false
            
            print("📚 Loaded \(allWords.count) words")
            
        } catch {
            errorMessage = "Failed to load words: \(error.localizedDescription)"
            isLoading = false
            print("❌ Failed to load words: \(error)")
        }
    }
    
    private func updateCurrentWord() {
        if currentWordIndex < remainingWords.count {
            currentWord = remainingWords[currentWordIndex]
            
            if currentWordIndex + 1 < remainingWords.count {
                nextWord = remainingWords[currentWordIndex + 1]
            } else {
                nextWord = nil
            }
        } else {
            currentWord = nil
            nextWord = nil
            isCompleted = true
        }
    }
    
    func swipeLeft() {
        guard let word = currentWord else { return }
        guard !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        soundManager.playSwipeLeft()
        
        undoStack.append(UndoAction(wordId: word.id, action: .hide))
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
        
        hiddenWordIds.insert(word.id)
        hiddenCount += 1
        
        saveSelections()
        currentWordIndex += 1
        updateCurrentWord()
        
        print("⬅️ Swiped left (skip): \(word.english) - FREE!")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.isProcessingSwipe = false
        }
    }
    
    func swipeRight() {
        guard let word = currentWord else { return }
        guard !isProcessingSwipe else { return }
        
        if !selectionLimitManager.canSelect() {
            selectionLimitReached = true
            print("❌ Daily selection limit reached!")
            return
        }
        
        isProcessingSwipe = true
        
        let remaining = selectionLimitManager.recordSelection()
        updateSelectionLimit()
        
        soundManager.playSwipeRight()
        
        undoStack.append(UndoAction(wordId: word.id, action: .select))
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
        
        selectedWordIds.insert(word.id)
        selectedCount += 1
        processedWords += 1
        
        saveSelections()
        currentWordIndex += 1
        updateCurrentWord()
        
        print("➡️ Swiped right (learn): \(word.english)")
        if let remaining = remaining {
            print("   Remaining: \(remaining)/15")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.isProcessingSwipe = false
        }
    }
    
    func undoLastAction() {
        guard let lastAction = undoStack.popLast() else {
            print("⚠️ No action to undo")
            return
        }
        
        if lastAction.action == .select {
            selectionLimitManager.undoSelection()
            updateSelectionLimit()
            
            if selectionLimitReached {
                selectionLimitReached = false
            }
        }
        
        guard let word = words.first(where: { $0.id == lastAction.wordId }) else {
            print("⚠️ Word not found for undo")
            return
        }
        
        soundManager.playClickSound()
        
        switch lastAction.action {
        case .select:
            selectedWordIds.remove(lastAction.wordId)
            selectedCount -= 1
            processedWords -= 1
            print("↩️ Undone select: \(word.english)")
            
        case .hide:
            hiddenWordIds.remove(lastAction.wordId)
            hiddenCount -= 1
            print("↩️ Undone skip: \(word.english)")
        }
        
        currentWordIndex = max(0, currentWordIndex - 1)
        updateCurrentWord()
        saveSelections()
    }
    
    func navigateToStudy() {
        saveSelections()
        print("📖 Navigating to study with \(selectedCount) selected words")
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
    }
}

private struct UndoAction {
    let wordId: Int
    let action: ActionType
    
    enum ActionType {
        case select
        case hide
    }
}
