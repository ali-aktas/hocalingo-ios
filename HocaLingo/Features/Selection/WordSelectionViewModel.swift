//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  FINAL VERSION - All errors fixed
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
    
    // MARK: - Private Properties
    private let packageId: String
    private var currentWordIndex: Int = 0
    private var remainingWords: [Word] = []
    private var selectedWordIds: Set<Int> = []
    private var hiddenWordIds: Set<Int> = []
    private var undoStack: [UndoAction] = []
    private let soundManager = SoundManager.shared
    private let jsonLoader = JSONLoader()
    
    // MARK: - Constants
    private let maxUndoStackSize = 5
    
    // MARK: - Initialization
    init(packageId: String) {
        self.packageId = packageId
        loadWords()
    }
    
    // MARK: - Load Words
    func loadWords() {
        isLoading = true
        errorMessage = nil
        
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            let allWords = vocabPackage.words
            let savedSelectedIds = UserDefaultsManager.shared.loadSelectedWords()
            selectedWordIds = Set(savedSelectedIds)
            
            let unseenWords = allWords.filter { word in
                !selectedWordIds.contains(word.id)
            }
            
            self.words = allWords
            self.remainingWords = unseenWords
            self.selectedCount = selectedWordIds.count
            self.hiddenCount = 0
            
            updateCurrentWord()
            isLoading = false
            
            print("📚 Loaded \(allWords.count) words, \(unseenWords.count) unseen")
            print("✅ Selected: \(selectedCount)")
            
        } catch {
            errorMessage = "Failed to load words: \(error.localizedDescription)"
            isLoading = false
            print("❌ Failed to load words: \(error)")
        }
    }
    
    // MARK: - Update Current Word
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
            
            if selectedCount > 0 {
                isCompleted = true
            }
        }
    }
    
    // MARK: - Swipe Actions (Wrapper Functions)
    
    func swipeLeft() {
        guard let word = currentWord else { return }
        hideWord(word.id)
    }
    
    func swipeRight() {
        guard let word = currentWord else { return }
        selectWord(word.id)
    }
    
    // MARK: - Select Word (Swipe Right)
    func selectWord(_ wordId: Int) {
        guard !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        soundManager.playSwipeRight()
        
        print("✅ Selecting word: \(wordId)")
        
        selectedWordIds.insert(wordId)
        selectedCount += 1
        
        createProgressForWord(wordId)
        addToUndoStack(UndoAction(wordId: wordId, action: .selected))
        saveSelections()
        
        NotificationCenter.default.post(
            name: NSNotification.Name("WordSelectionChanged"),
            object: nil
        )
        print("📡 Notification posted: WordSelectionChanged")
        
        moveToNextWord()
        isProcessingSwipe = false
    }
    
    // MARK: - Hide Word (Swipe Left)
    func hideWord(_ wordId: Int) {
        guard !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        soundManager.playSwipeLeft()
        
        print("❌ Hiding word: \(wordId)")
        
        hiddenCount += 1
        addToUndoStack(UndoAction(wordId: wordId, action: .hidden))
        moveToNextWord()
        isProcessingSwipe = false
    }
    
    // MARK: - Move to Next Word
    private func moveToNextWord() {
        currentWordIndex += 1
        processedWords += 1
        
        print("➡️ Moving to next word: \(currentWordIndex) / \(remainingWords.count)")
        
        updateCurrentWord()
    }
    
    // MARK: - Undo
    func undo() {
        guard !undoStack.isEmpty, !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        soundManager.playClickSound()
        
        let lastAction = undoStack.removeLast()
        
        print("↩️ Undoing action: \(lastAction.action) for word \(lastAction.wordId)")
        
        switch lastAction.action {
        case .selected:
            selectedWordIds.remove(lastAction.wordId)
            selectedCount -= 1
            deleteProgressForWord(lastAction.wordId)
            
        case .hidden:
            hiddenCount -= 1
        }
        
        saveSelections()
        
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            processedWords -= 1
            updateCurrentWord()
        }
        
        if isCompleted {
            isCompleted = false
        }
        
        isProcessingSwipe = false
    }
    
    // MARK: - Undo Stack Management
    private func addToUndoStack(_ action: UndoAction) {
        undoStack.append(action)
        
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty && !isProcessingSwipe
    }
    
    // MARK: - Progress Creation
    
    private func createProgressForWord(_ wordId: Int) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        
        for direction in directions {
            let existingProgress = UserDefaultsManager.shared.loadProgress(for: wordId, direction: direction)
            
            if existingProgress == nil {
                let newProgress = Progress(wordId: wordId, direction: direction)
                UserDefaultsManager.shared.saveProgress(newProgress, for: wordId, direction: direction)
                
                print("📝 Created progress: wordId=\(wordId), direction=\(direction.displayName)")
            }
        }
    }
    
    private func deleteProgressForWord(_ wordId: Int) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        
        for direction in directions {
            UserDefaultsManager.shared.deleteProgress(for: wordId, direction: direction)
            print("🗑️ Deleted progress: wordId=\(wordId), direction=\(direction.displayName)")
        }
    }
    
    // MARK: - Save Selections
    private func saveSelections() {
        let selectedArray = Array(selectedWordIds)
        UserDefaultsManager.shared.saveSelectedWords(selectedArray)
        
        print("💾 Saved \(selectedWordIds.count) selected words")
    }
    
    // MARK: - Finish Selection
    func finishSelection() {
        guard selectedCount > 0 else {
            print("⚠️ No words selected")
            return
        }
        
        print("✅ Finishing selection: \(selectedCount) words selected")
        
        UserDefaultsManager.shared.saveSelectedPackage(packageId)
        
        let selectedArray = Array(selectedWordIds)
        UserDefaultsManager.shared.saveSelectedWords(selectedArray)
        
        for wordId in selectedWordIds {
            createProgressForWord(wordId)
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("WordSelectionChanged"),
            object: nil
        )
        print("📡 Final notification posted: WordSelectionChanged")
        print("   - Package: \(packageId)")
        print("   - Words: \(selectedArray)")
        print("   - Progress records: \(selectedCount * 2) (both directions)")
    }
    
    // MARK: - Reset All
    func resetAllSelections() {
        selectedWordIds.removeAll()
        hiddenWordIds.removeAll()
        selectedCount = 0
        hiddenCount = 0
        currentWordIndex = 0
        processedWords = 0
        undoStack.removeAll()
        isCompleted = false
        
        saveSelections()
        loadWords()
    }
    
    // MARK: - Get Random Card Color
    func getCardColor(for word: Word) -> Color {
        Color.pastelColor(for: word.id)
    }
}

// MARK: - Undo Action
struct UndoAction {
    let wordId: Int
    let action: SelectionAction
}

enum SelectionAction {
    case selected
    case hidden
}
