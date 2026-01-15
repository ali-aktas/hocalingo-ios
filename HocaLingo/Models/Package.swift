//
//  Package.swift
//  HocaLingo
//
//  Models package - Package metadata for UI
//

import Foundation

// MARK: - Package Model
/// Simplified package model for UI display
/// Contains metadata about word packages
struct Package: Identifiable {
    let id: String // e.g., "en_tr_a1_001"
    let level: String // A1, A2, B1, B2, C1, C2
    let totalWords: Int
    let description: String
    var isDownloaded: Bool
    var downloadedWordCount: Int
    
    // Computed properties
    var displayTitle: String {
        "\(level) Package"
    }
    
    var downloadProgress: Double {
        guard totalWords > 0 else { return 0 }
        return Double(downloadedWordCount) / Double(totalWords)
    }
    
    var isFullyDownloaded: Bool {
        downloadedWordCount >= totalWords
    }
    
    var hasNewWords: Bool {
        !isFullyDownloaded && downloadedWordCount > 0
    }
    
    var newWordsCount: Int {
        max(0, totalWords - downloadedWordCount)
    }
}
