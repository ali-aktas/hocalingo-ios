//
//  WordSelectionViewModel.swift
//  HocaLingo
//
//  Updated on 15.01.2026.
//

import SwiftUI
import Combine

// MARK: - Word Selection View Model
/// Business logic for word selection screen with persistence
/// Location: HocaLingo/Features/Selection/WordSelectionViewModel.swift
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
    
    /// Finish selection and save to UserDefaults
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
        
        print("✅ Selection finished: \(selectedCount) words saved")
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
