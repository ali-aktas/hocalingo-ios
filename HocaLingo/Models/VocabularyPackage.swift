//
//  VocabularyPackage.swift
//  HocaLingo
//
//  Models package - Complete vocabulary package structure
//

import Foundation

// MARK: - Vocabulary Package Model
/// Complete vocabulary package containing metadata and words
/// Matches Android's VocabularyPackageJson structure
struct VocabularyPackage: Codable {
    let packageInfo: PackageInfo
    let words: [Word]
    
    // Custom coding keys to match JSON snake_case
    enum CodingKeys: String, CodingKey {
        case packageInfo = "package_info"
        case words
    }
}
