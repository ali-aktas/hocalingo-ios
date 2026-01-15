//
//  PackageInfo.swift
//  HocaLingo
//
//  Models package - Package metadata structure
//

import Foundation

// MARK: - Package Info Model
/// Metadata for vocabulary packages
/// Matches Android's PackageInfoJson structure
struct PackageInfo: Codable {
    let id: String
    let version: String
    let level: String
    let languagePair: String
    let totalWords: Int
    let updatedAt: String
    let description: String
    let attribution: String
    
    // Custom coding keys to match JSON snake_case
    enum CodingKeys: String, CodingKey {
        case id
        case version
        case level
        case languagePair = "language_pair"
        case totalWords = "total_words"
        case updatedAt = "updated_at"
        case description
        case attribution
    }
}
