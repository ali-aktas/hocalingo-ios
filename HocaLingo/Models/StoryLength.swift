//
//  StoryLength.swift
//  HocaLingo
//
//  AI Story Generation - Story Length Classification
//  ✅ REDESIGNED: Higher deck word counts + SF Symbols
//  Location: HocaLingo/Models/StoryLength.swift
//

import Foundation
import SwiftUI

/// Story length classification
/// Determines word count and vocabulary complexity
/// ✅ REDESIGNED: More deck words + emoji removed
enum StoryLength: String, Codable, CaseIterable, Identifiable {
    case short  // ~220 words, 20 deck words
    case long   // ~600 words, 45 deck words
    
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
    
    /// ✅ SF Symbol icon (replaces emoji)
    var iconName: String {
        switch self {
        case .short:
            return "doc.text"
        case .long:
            return "doc.text.fill"
        }
    }
    
    /// ✅ DEPRECATED: Old emoji icon - kept for backward compatibility
    var icon: String {
        switch self {
        case .short:
            return "doc.text"
        case .long:
            return "doc.text.fill"
        }
    }
    
    /// Target word count for generated story
    var targetWordCount: Int {
        switch self {
        case .short:
            return 220
        case .long:
            return 600
        }
    }
    
    /// ✅ INCREASED: Exact deck words to include
    /// SHORT: 20 words (was 15)
    /// LONG: 45 words (was 30)
    /// More deck words = higher English density
    var exactDeckWords: Int {
        switch self {
        case .short:
            return 20
        case .long:
            return 45
        }
    }
    
    /// Maximum tokens for Gemini API
    /// Controls output length and cost
    var maxTokens: Int {
        switch self {
        case .short:
            return 500   // Slightly increased for denser English
        case .long:
            return 1200  // Slightly increased for denser English
        }
    }
    
    /// Estimated reading time
    var estimatedReadTime: LocalizedStringKey {
        switch self {
        case .short:
            return "story_read_time_short"
        case .long:
            return "story_read_time_long"
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
