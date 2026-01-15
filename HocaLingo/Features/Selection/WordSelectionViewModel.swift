import SwiftUI
import Combine

// MARK: - Word Selection View Model
/// Business logic for word selection screen
/// Location: HocaLingo/Features/Selection/WordSelectionViewModel.swift
class WordSelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var words: [Word] = []
    @Published var selectedWordIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    var selectedCount: Int {
        selectedWordIds.count
    }
    
    // MARK: - Private Properties
    private let packageId: String
    private let jsonLoader = JSONLoader()
    
    // MARK: - Initialization
    init(packageId: String) {
        self.packageId = packageId
        loadWords()
        loadPreviousSelection()
    }
    
    // MARK: - Load Words
    func loadWords() {
        isLoading = true
        errorMessage = nil
        
        // Load words from JSON
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
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
    
    // MARK: - Selection Management
    func toggleWordSelection(_ wordId: Int) {
        if selectedWordIds.contains(wordId) {
            selectedWordIds.remove(wordId)
        } else {
            selectedWordIds.insert(wordId)
        }
        
        // Save to UserDefaults
        saveSelection()
    }
    
    func isWordSelected(_ wordId: Int) -> Bool {
        selectedWordIds.contains(wordId)
    }
    
    func clearSelection() {
        selectedWordIds.removeAll()
        saveSelection()
    }
    
    func finishSelection() {
        guard selectedCount > 0 else {
            print("⚠️ No words selected")
            return
        }
        
        print("✅ Selection finished: \(selectedCount) words")
        saveSelection()
        
        // TODO: Navigate to study screen
    }
    
    // MARK: - Persistence (UserDefaults)
    private func saveSelection() {
        let selectedArray = Array(selectedWordIds)
        UserDefaults.standard.set(selectedArray, forKey: "selectedWords_\(packageId)")
        print("💾 Saved \(selectedCount) words to UserDefaults")
    }
    
    private func loadPreviousSelection() {
        if let savedIds = UserDefaults.standard.array(forKey: "selectedWords_\(packageId)") as? [Int] {
            selectedWordIds = Set(savedIds)
            print("📂 Loaded \(selectedCount) previously selected words")
        }
    }
    
    // MARK: - Helper Methods
    func getSelectedWords() -> [Word] {
        words.filter { selectedWordIds.contains($0.id) }
    }
}
