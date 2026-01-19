//
//  UserDefaultsManager+Sync.swift
//  HocaLingo
//
//  ✅ NEW CRITICAL FIX: Sync package selections with global selected words list
//  This extension ensures package-specific selections are reflected in the global list
//
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+Sync.swift
//

import Foundation

// MARK: - Sync Extension (CRITICAL FIX)
extension UserDefaultsManager {
    
    /// ✅ CRITICAL: Sync all package selections into the global selected words list
    /// Call this after any word selection changes
    func syncGlobalSelectedWords() {
        var allSelectedIds = Set<Int>()
        
        // Get all UserDefaults keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        
        // Find all package selection keys
        for key in allKeys {
            if key.contains("_selected") && !key.contains("_hidden") {
                if let packageSelected = UserDefaults.standard.array(forKey: key) as? [Int] {
                    allSelectedIds.formUnion(packageSelected)
                }
            }
        }
        
        // Add user-added words
        let userWords = loadUserAddedWords()
        let userWordIds = userWords.map { $0.id }
        allSelectedIds.formUnion(userWordIds)
        
        // Save to global list
        let globalList = Array(allSelectedIds).sorted()
        saveSelectedWords(globalList)
        
        print("🔄 SYNC: Global selected words updated: \(globalList.count) words")
    }
    
    /// ✅ NEW: Add a single word to global selected list
    /// Use this when adding user words or selecting a word programmatically
    func addToSelectedWords(_ wordId: Int) {
        var currentSelected = loadSelectedWords()
        
        if !currentSelected.contains(wordId) {
            currentSelected.append(wordId)
            saveSelectedWords(currentSelected)
            print("➕ Added word \(wordId) to global selected list")
        }
    }
    
    /// ✅ NEW: Remove a word from global selected list
    func removeFromSelectedWords(_ wordId: Int) {
        var currentSelected = loadSelectedWords()
        
        if let index = currentSelected.firstIndex(of: wordId) {
            currentSelected.remove(at: index)
            saveSelectedWords(currentSelected)
            print("➖ Removed word \(wordId) from global selected list")
        }
    }
    
    /// ✅ NEW: Add multiple words to global selected list
    func addToSelectedWords(_ wordIds: [Int]) {
        var currentSelected = Set(loadSelectedWords())
        currentSelected.formUnion(wordIds)
        saveSelectedWords(Array(currentSelected).sorted())
        print("➕ Added \(wordIds.count) words to global selected list")
    }
}
