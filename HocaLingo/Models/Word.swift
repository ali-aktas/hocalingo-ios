//
//  Word.swift
//  HocaLingo
//
//  Models package - Core word data structure
//

import Foundation

// MARK: - Word Model
/// Represents a vocabulary word with translation and example sentences
/// Matches Android's WordJson structure
struct Word: Codable, Identifiable {
    let id: Int
    let english: String
    let turkish: String
    let example: Example
    let pronunciation: String
    let level: String
    let category: String
    let reversible: Bool
    let userAdded: Bool
}

// MARK: - Example Model
/// Example sentences in both languages
struct Example: Codable {
    let en: String
    let tr: String
}
