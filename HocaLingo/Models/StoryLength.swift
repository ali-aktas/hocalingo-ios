//
//  StoryLength.swift
//  HocaLingo
//
//  AI Story Generation - Story Length Classification
//  ✅ UPDATED: Exact word counts (20 and 40) - NO ranges
//  Location: HocaLingo/Models/StoryLength.swift
//

import Foundation
import SwiftUI

/// Story length classification
/// Determines word count and vocabulary complexity
enum StoryLength: String, Codable, CaseIterable, Identifiable {
    case short  // ~180 words, exactly 20 deck words
    case long   // ~600 words, exactly 40 deck words
    
    var id: String { rawValue }
    
    /// Localized display name
    /// Keys: "story_length_short", "story_length_long"
    var displayName: LocalizedStringKey {
        switch self {
        case .short:
            return "story_length_short"
        case .long:
            return "story_length_long"
        }
    }
    
    /// Emoji icon for UI
    var icon: String {
        switch self {
        case .short:
            return "📄"
        case .long:
            return "📚"
        }
    }
    
    /// Target word count for generated story
    /// +20% increase from Android version
    var targetWordCount: Int {
        switch self {
        case .short:
            return 180  // 150 + 20%
        case .long:
            return 600  // 500 + 20%
        }
    }
    
    /// Exact deck words to include
    /// SHORT: Exactly 20 words
    /// LONG: Exactly 40 words
    /// ✅ NO ranges - AI must use this EXACT count
    var exactDeckWords: Int {
        switch self {
        case .short:
            return 20
        case .long:
            return 40
        }
    }
    
    /// Maximum tokens for Gemini API
    /// Controls output length and cost
    var maxTokens: Int {
        switch self {
        case .short:
            return 300   // ~180 words
        case .long:
            return 900   // ~600 words
        }
    }
    
    /// Estimated reading time
    var estimatedReadTime: String {
        switch self {
        case .short:
            return "1-2 dk"
        case .long:
            return "5-7 dk"
        }
    }
    
    /// Premium status - only Long is premium
    var isPremium: Bool {
        switch self {
        case .long:
            return true
        case .short:
            return false
        }
    }
}
