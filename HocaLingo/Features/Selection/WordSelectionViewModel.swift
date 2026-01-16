//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Dual progress creation (EN→TR + TR→EN) for each word
//  Location: HocaLingo/Features/Selection/WordSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Word Selection View Model
/// Business logic for word selection screen with persistence
/// ✅ Creates independent progress for both study directions
class WordSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var words: [Word] = []
    @Published var selectedWordIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
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
        loadPreviousSelection()
    }
    
    // MARK: - Data Loading
    
    /// Load words from JSON file
    func loadWords() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Load vocabulary package (throws error, doesn't return optional)
                let vocabularyPackage = try self.jsonLoader.loadVocabularyPackage(filename: self.packageId)
                
                DispatchQueue.main.async {
                    self.words = vocabularyPackage.words
                    self.isLoading = false
                    print("✅ Loaded \(self.words.count) words from \(self.packageId)")
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load words: \(error.localizedDescription)"
                    self.isLoading = false
                    print("❌ Error loading words: \(error)")
                }
            }
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
    
    /// ✅ UPDATED: Finish selection and create dual progress for each word
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
        
        print("✅ Selection finished:")
        print("   - Words selected: \(selectedCount)")
        print("   - Progress records created: \(selectedCount * 2) (both directions)")
    }
    
    /// ✅ NEW: Create progress for both directions (EN→TR and TR→EN)
    /// This ensures each word has independent progress tracking for each study direction
    private func createDualProgressForSelectedWords(_ wordIds: [Int]) {
        let currentTime = Date()
        var progressCreatedCount = 0
        
        for wordId in wordIds {
            // ✅ Check if progress already exists for both directions
            let existingProgressEnToTr = UserDefaultsManager.shared.loadProgress(for: wordId, direction: .enToTr)
            let existingProgressTrToEn = UserDefaultsManager.shared.loadProgress(for: wordId, direction: .trToEn)
            
            // ✅ Create EN→TR progress if not exists
            if existingProgressEnToTr == nil {
                let progressEnToTr = Progress(
                    wordId: wordId,
                    direction: .enToTr,
                    repetitions: 0,
                    intervalDays: 0,
                    easeFactor: 2.5,
                    nextReviewAt: currentTime,
                    lastReviewAt: nil,
                    learningPhase: true,
                    sessionPosition: 1,
                    successfulReviews: 0,
                    hardPresses: 0,
                    isSelected: true,
                    isMastered: false,
                    createdAt: currentTime,
                    updatedAt: currentTime
                )
                
                UserDefaultsManager.shared.saveProgress(progressEnToTr, for: wordId)
                progressCreatedCount += 1
                
                print("   ✅ Created EN→TR progress for word \(wordId)")
            }
            
            // ✅ Create TR→EN progress if not exists
            if existingProgressTrToEn == nil {
                let progressTrToEn = Progress(
                    wordId: wordId,
                    direction: .trToEn,
                    repetitions: 0,
                    intervalDays: 0,
                    easeFactor: 2.5,
                    nextReviewAt: currentTime,
                    lastReviewAt: nil,
                    learningPhase: true,
                    sessionPosition: 1,
                    successfulReviews: 0,
                    hardPresses: 0,
                    isSelected: true,
                    isMastered: false,
                    createdAt: currentTime,
                    updatedAt: currentTime
                )
                
                UserDefaultsManager.shared.saveProgress(progressTrToEn, for: wordId)
                progressCreatedCount += 1
                
                print("   ✅ Created TR→EN progress for word \(wordId)")
            }
        }
        
        print("   📊 Total new progress records: \(progressCreatedCount)")
    }
    
    // MARK: - Persistence
    
    /// Load previously selected words
    private func loadPreviousSelection() {
        let savedWordIds = UserDefaultsManager.shared.loadSelectedWords()
        selectedWordIds = Set(savedWordIds)
        
        if !savedWordIds.isEmpty {
            print("📂 Loaded \(selectedCount) previously selected words")
        }
    }
    
    /// Get selected words as array
    func getSelectedWords() -> [Word] {
        return words.filter { selectedWordIds.contains($0.id) }
    }
}
