//
//  Word.swift
//  HocaLingo
//
//  Models package - Core word data structure
//  ✅ UPDATED: meanings array support (multi-meaning words)
//  ✅ Backward compatible: old JSON format + old init still work
//

import Foundation

// MARK: - Meaning Model
/// Single meaning entry with Turkish translation and example
struct Meaning: Codable, Equatable {
    let turkish: String
    let example: Example
}

// MARK: - Example Model
/// Example sentences in both languages
struct Example: Codable, Equatable {
    let en: String
    let tr: String
}

// MARK: - Word Model
/// Represents a vocabulary word with one or more meanings
struct Word: Codable, Identifiable, Equatable {
    let id: Int
    let english: String
    let pronunciation: String
    let level: String
    let category: String
    let reversible: Bool
    let userAdded: Bool
    let meanings: [Meaning]

    // MARK: - Backward Compat Computed Properties
    // These let ALL existing code (word.turkish, word.example) keep working

    /// Primary Turkish translation (first meaning)
    var turkish: String {
        meanings.first?.turkish ?? ""
    }

    /// Primary example (first meaning)
    var example: Example {
        meanings.first?.example ?? Example(en: "", tr: "")
    }

    /// All Turkish meanings joined — "ışık, hafif"
    var allTurkishMeanings: String {
        meanings.map { $0.turkish }.joined(separator: ", ")
    }

    // MARK: - Convenience Init (Old Style)
    // AddWordDialogView and other places that create Word with single meaning

    init(
        id: Int,
        english: String,
        turkish: String,
        example: Example,
        pronunciation: String,
        level: String,
        category: String,
        reversible: Bool,
        userAdded: Bool
    ) {
        self.id = id
        self.english = english
        self.pronunciation = pronunciation
        self.level = level
        self.category = category
        self.reversible = reversible
        self.userAdded = userAdded
        self.meanings = [Meaning(turkish: turkish, example: example)]
    }

    // MARK: - Full Init (New Style)

    init(
        id: Int,
        english: String,
        pronunciation: String,
        level: String,
        category: String,
        reversible: Bool,
        userAdded: Bool,
        meanings: [Meaning]
    ) {
        self.id = id
        self.english = english
        self.pronunciation = pronunciation
        self.level = level
        self.category = category
        self.reversible = reversible
        self.userAdded = userAdded
        self.meanings = meanings
    }

    // MARK: - Custom Decoder (handles BOTH old and new JSON)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        english = try container.decode(String.self, forKey: .english)
        pronunciation = try container.decodeIfPresent(String.self, forKey: .pronunciation) ?? ""
        level = try container.decode(String.self, forKey: .level)
        category = try container.decode(String.self, forKey: .category)
        reversible = try container.decodeIfPresent(Bool.self, forKey: .reversible) ?? true
        userAdded = try container.decodeIfPresent(Bool.self, forKey: .userAdded) ?? false

        // Try NEW format first (meanings array)
        if let meaningsArray = try? container.decode([Meaning].self, forKey: .meanings) {
            meanings = meaningsArray
        }
        // Fallback to OLD format (turkish + example at root)
        else if let turkish = try? container.decode(String.self, forKey: .turkish) {
            let example = try container.decodeIfPresent(Example.self, forKey: .example)
                ?? Example(en: "", tr: "")
            meanings = [Meaning(turkish: turkish, example: example)]
        }
        // Edge case: neither exists
        else {
            meanings = []
        }
    }

    // MARK: - Custom Encoder (always writes NEW format)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(english, forKey: .english)
        try container.encode(pronunciation, forKey: .pronunciation)
        try container.encode(level, forKey: .level)
        try container.encode(category, forKey: .category)
        try container.encode(reversible, forKey: .reversible)
        try container.encode(userAdded, forKey: .userAdded)
        try container.encode(meanings, forKey: .meanings)
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id, english, pronunciation, level, category, reversible, userAdded
        case meanings
        // Old format keys (only used in decoder)
        case turkish, example
    }
}
