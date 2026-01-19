//
//  UserDefaultsManager+UserWords.swift
//  HocaLingo
//
//  ✅ NEW: Extension for managing user-added custom words
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+UserWords.swift
//

import Foundation

// MARK: - User Words Management Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    
    private enum UserWordsKeys {
        static let userAddedWords = "user_added_words"
        static let userWordCount = "user_word_count"
    }
    
    // MARK: - Save User-Added Words
    
    /// Save all user-added words
    func saveUserAddedWords(_ words: [Word]) {
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: UserWordsKeys.userAddedWords)
            UserDefaults.standard.set(words.count, forKey: UserWordsKeys.userWordCount)
        }
    }
    
    // MARK: - Load User-Added Words
    
    /// Load all user-added words
    func loadUserAddedWords() -> [Word] {
        guard let data = UserDefaults.standard.data(forKey: UserWordsKeys.userAddedWords),
              let words = try? JSONDecoder().decode([Word].self, from: data) else {
            return []
        }
        return words
    }
    
    /// Get count of user-added words
    func getUserWordCount() -> Int {
        return UserDefaults.standard.integer(forKey: UserWordsKeys.userWordCount)
    }
    
    // MARK: - Add Single Word
    
    /// Add a single user word
    func addUserWord(_ word: Word) {
        var words = loadUserAddedWords()
        words.append(word)
        saveUserAddedWords(words)
    }
    
    // MARK: - Delete User Word
    
    /// Delete a user word by ID
    func deleteUserWord(id: Int) {
        var words = loadUserAddedWords()
        words.removeAll { $0.id == id }
        saveUserAddedWords(words)
    }
    
    // MARK: - Check if Word Exists
    
    /// Check if a word already exists (by English text)
    func wordExists(english: String) -> Bool {
        let words = loadUserAddedWords()
        return words.contains { $0.english.lowercased() == english.lowercased() }
    }
    
    // MARK: - Get User Word by ID
    
    /// Get a specific user word by ID
    func getUserWord(id: Int) -> Word? {
        let words = loadUserAddedWords()
        return words.first { $0.id == id }
    }
}
