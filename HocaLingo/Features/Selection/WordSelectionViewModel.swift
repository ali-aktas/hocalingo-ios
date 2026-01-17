import SwiftUI
import Combine

// MARK: - Word Selection ViewModel (FIXED)
/// Production-grade ViewModel with CORRECT UserDefaults integration
/// FIXES:
/// - Uses correct saveSelectedWords() and loadSelectedWords()
/// - Removed hidden words (iOS doesn't need it)
/// - Proper package saving
/// Location: HocaLingo/Features/WordSelection/WordSelectionViewModel.swift
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
            // Load vocabulary package using JSONLoader
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            
            // Get all words from package
            let allWords = vocabPackage.words
            
            // ✅ FIXED: Load saved selections using CORRECT function
            let savedSelectedIds = UserDefaultsManager.shared.loadSelectedWords()
            selectedWordIds = Set(savedSelectedIds)
            
            // Filter unseen words (not selected)
            let unseenWords = allWords.filter { word in
                !selectedWordIds.contains(word.id)
            }
            
            self.words = allWords
            self.remainingWords = unseenWords
            self.selectedCount = selectedWordIds.count
            self.hiddenCount = 0 // iOS doesn't use hidden feature
            
            // Set current and next word
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
            
            // Set next word (preview card)
            if currentWordIndex + 1 < remainingWords.count {
                nextWord = remainingWords[currentWordIndex + 1]
            } else {
                nextWord = nil
            }
        } else {
            // All words processed
            currentWord = nil
            nextWord = nil
            
            // Check if completed
            if selectedCount > 0 {
                isCompleted = true
            }
        }
    }
    
    // MARK: - Select Word (Swipe Right)
    func selectWord(_ wordId: Int) {
        guard !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        
        // Play sound
        soundManager.playSwipeRight()
        
        print("✅ Selecting word: \(wordId)")
        
        // Add to selected
        selectedWordIds.insert(wordId)
        selectedCount += 1
        
        // Create progress for this word (EN→TR + TR→EN)
        createProgressForWord(wordId)
        
        // Add to undo stack
        addToUndoStack(UndoAction(wordId: wordId, action: .selected))
        
        // ✅ FIXED: Save using CORRECT function
        saveSelections()
        
        // Notify StudyViewModel about selection change
        NotificationCenter.default.post(
            name: NSNotification.Name("WordSelectionChanged"),
            object: nil
        )
        print("📡 Notification posted: WordSelectionChanged")
        
        // Move to next word
        moveToNextWord()
        
        isProcessingSwipe = false
    }
    
    // MARK: - Hide Word (Swipe Left)
    func hideWord(_ wordId: Int) {
        guard !isProcessingSwipe else { return }
        
        isProcessingSwipe = true
        
        // Play sound
        soundManager.playSwipeLeft()
        
        print("❌ Hiding word: \(wordId)")
        
        // Just skip (don't save as hidden in iOS)
        hiddenCount += 1
        
        // Add to undo stack
        addToUndoStack(UndoAction(wordId: wordId, action: .hidden))
        
        // Move to next word
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
        
        // Play sound
        soundManager.playClickSound()
        
        let lastAction = undoStack.removeLast()
        
        print("↩️ Undoing action: \(lastAction.action) for word \(lastAction.wordId)")
        
        // Revert action
        switch lastAction.action {
        case .selected:
            selectedWordIds.remove(lastAction.wordId)
            selectedCount -= 1
            
            // Remove progress for this word
            deleteProgressForWord(lastAction.wordId)
            
        case .hidden:
            hiddenCount -= 1
        }
        
        // Save to UserDefaults
        saveSelections()
        
        // Move back one word
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            processedWords -= 1
            updateCurrentWord()
        }
        
        // Reset completion if needed
        if isCompleted {
            isCompleted = false
        }
        
        isProcessingSwipe = false
    }
    
    // MARK: - Undo Stack Management
    private func addToUndoStack(_ action: UndoAction) {
        undoStack.append(action)
        
        // Limit stack size
        if undoStack.count > maxUndoStackSize {
            undoStack.removeFirst()
        }
    }
    
    var canUndo: Bool {
        !undoStack.isEmpty && !isProcessingSwipe
    }
    
    // MARK: - Progress Creation
    
    /// Create dual progress (EN→TR + TR→EN) for a word
    private func createProgressForWord(_ wordId: Int) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        
        for direction in directions {
            // Check if progress already exists
            let existingProgress = UserDefaultsManager.shared.loadProgress(for: wordId, direction: direction)
            
            if existingProgress == nil {
                // Create new progress
                let newProgress = Progress(wordId: wordId, direction: direction)
                UserDefaultsManager.shared.saveProgress(newProgress, for: wordId, direction: direction)
                
                print("📝 Created progress: wordId=\(wordId), direction=\(direction.displayName)")
            }
        }
    }
    
    /// Delete dual progress (EN→TR + TR→EN) for a word (used in undo)
    private func deleteProgressForWord(_ wordId: Int) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        
        for direction in directions {
            UserDefaultsManager.shared.deleteProgress(for: wordId, direction: direction)
            print("🗑️ Deleted progress: wordId=\(wordId), direction=\(direction.displayName)")
        }
    }
    
    // MARK: - Save Selections (FIXED)
    private func saveSelections() {
        // ✅ FIXED: Use correct UserDefaults functions
        let selectedArray = Array(selectedWordIds)
        UserDefaultsManager.shared.saveSelectedWords(selectedArray)
        
        print("💾 Saved \(selectedWordIds.count) selected words")
    }
    
    // MARK: - Finish Selection (FIXED)
    func finishSelection() {
        guard selectedCount > 0 else {
            print("⚠️ No words selected")
            return
        }
        
        print("✅ Finishing selection: \(selectedCount) words selected")
        
        // ✅ FIXED: Save package ID using correct function
        UserDefaultsManager.shared.saveSelectedPackage(packageId)
        
        // ✅ FIXED: Save selected words
        let selectedArray = Array(selectedWordIds)
        UserDefaultsManager.shared.saveSelectedWords(selectedArray)
        
        // Create progress for any remaining selected words that don't have it
        for wordId in selectedWordIds {
            createProgressForWord(wordId)
        }
        
        // Notify StudyViewModel
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
        
        // Reload words
        loadWords()
    }
    
    // MARK: - Get Random Card Color
    func getCardColor(for word: Word) -> Color {
        let hash = abs((word.english + word.turkish).hashValue)
        let index = hash % cardColors.count
        return cardColors[index]
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

// MARK: - Preview
#Preview {
    WordSelectionView(packageId: "basic")
}
