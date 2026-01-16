//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  ✅ MEGA UPDATE: NotificationCenter post after word selection (real-time update)
//  Location: HocaLingo/Features/Selection/WordSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Word Selection View Model
/// Business logic for word selection with dual progress creation
class WordSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var words: [Word] = []
    @Published var selectedWordIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private let packageId: String
    private let jsonLoader = JSONLoader()
    
    // MARK: - Computed Properties
    var selectedCount: Int {
        return selectedWordIds.count
    }
    
    // MARK: - Initialization
    init(packageId: String) {
        self.packageId = packageId
        loadWords()
    }
    
    // MARK: - Data Loading
    func loadWords() {
        isLoading = true
        errorMessage = nil
        
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            words = vocabPackage.words
            isLoading = false
            
            print("✅ Loaded \(words.count) words from package: \(packageId)")
        } catch {
            errorMessage = "Failed to load words: \(error.localizedDescription)"
            isLoading = false
            
            print("❌ Failed to load words: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Selection Actions
    
    /// Toggle word selection
    func toggleWordSelection(_ wordId: Int) {
        if selectedWordIds.contains(wordId) {
            selectedWordIds.remove(wordId)
        } else {
            selectedWordIds.insert(wordId)
        }
    }
    
    /// Check if word is selected
    func isWordSelected(_ wordId: Int) -> Bool {
        return selectedWordIds.contains(wordId)
    }
    
    /// Select all words
    func selectAll() {
        selectedWordIds = Set(words.map { $0.id })
    }
    
    /// Clear all selections
    func clearSelection() {
        selectedWordIds.removeAll()
    }
    
    /// ✅ MEGA FIX 3: Finish selection + NotificationCenter
    func finishSelection() {
        guard selectedCount > 0 else {
            print("⚠️ No words selected")
            return
        }
        
        let wordIdsArray = Array(selectedWordIds).sorted()
        
        // Save selected words
        UserDefaultsManager.shared.saveSelectedWords(wordIdsArray)
        
        // Save selected package
        UserDefaultsManager.shared.saveSelectedPackage(packageId)
        
        // ✅ CRITICAL: Create dual progress for each selected word
        createDualProgressForSelectedWords(wordIdsArray)
        
        // ✅ NEW: Post notification to StudyViewModel
        NotificationCenter.default.post(
            name: NSNotification.Name("WordSelectionChanged"),
            object: nil
        )
        
        print("✅ Selection finished:")
        print("   - Words selected: \(selectedCount)")
        print("   - Progress records created: \(selectedCount * 2) (both directions)")
        print("   📡 Notification posted to StudyViewModel")
    }
    
    /// ✅ NEW: Create progress for both directions (EN→TR and TR→EN)
    /// This ensures each word has independent progress tracking for each study direction
    private func createDualProgressForSelectedWords(_ wordIds: [Int]) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        
        for wordId in wordIds {
            for direction in directions {
                // Check if progress already exists for this word+direction
                let existingProgress = UserDefaultsManager.shared.loadProgress(for: wordId, direction: direction)
                
                if existingProgress == nil {
                    // Create new progress
                    let newProgress = Progress(wordId: wordId, direction: direction)
                    UserDefaultsManager.shared.saveProgress(newProgress, for: wordId)
                    
                    print("📝 Created progress: wordId=\(wordId), direction=\(direction.displayName)")
                }
            }
        }
    }
}
