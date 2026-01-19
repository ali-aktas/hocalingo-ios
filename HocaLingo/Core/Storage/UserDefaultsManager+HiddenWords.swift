//
//  UserDefaultsManager+HiddenWords.swift
//  HocaLingo
//
//  Hidden words count tracking extension
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+HiddenWords.swift
//

import Foundation

// MARK: - Hidden Words Tracking Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum HiddenWordsKeys {
        static let totalHiddenWords = "total_hidden_words_count"
    }
    
    // MARK: - Hidden Words Count
    
    /// Get total count of all hidden words across all packages
    /// This is used for annual stats display
    func getTotalHiddenWordsCount() -> Int {
        // Calculate from all packages
        var totalHidden = 0
        
        // Get all package IDs from UserDefaults
        // We need to iterate through all saved hidden word arrays
        if let allKeys = UserDefaults.standard.dictionaryRepresentation().keys as? [String] {
            for key in allKeys {
                // Check if this is a hidden words key (format: "package_X_hidden")
                if key.hasSuffix("_hidden") {
                    if let hiddenWords = UserDefaults.standard.array(forKey: key) as? [Int] {
                        totalHidden += hiddenWords.count
                    }
                }
            }
        }
        
        return totalHidden
    }
    
    /// Mark a word as hidden (called from word selection)
    /// This increments the hidden words counter
    func markWordAsHidden(wordId: Int, packageId: String) {
        // Get current selections
        var (selected, hidden) = getWordSelections(packageId: packageId)
        
        // Add to hidden if not already there
        if !hidden.contains(wordId) {
            hidden.append(wordId)
        }
        
        // Remove from selected if it was there
        if let index = selected.firstIndex(of: wordId) {
            selected.remove(at: index)
        }
        
        // Save updated selections
        saveWordSelections(packageId: packageId, selected: selected, hidden: hidden)
        
        print("📊 Word marked as hidden: \(wordId)")
        print("   - Package: \(packageId)")
        print("   - Total hidden in package: \(hidden.count)")
    }
}
