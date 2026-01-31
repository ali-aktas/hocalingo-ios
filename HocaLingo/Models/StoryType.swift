//
//  StoryType.swift
//  HocaLingo
//
//  AI Story Generation - Story Type Enum
//  3 types: Motivation, Fantasy (kid-friendly), Dialogue
//

import Foundation
import SwiftUI

/// Story type classification
/// Defines the style and format of generated stories
enum StoryType: String, Codable, CaseIterable, Identifiable {
    case motivation  // Motivational/inspirational content
    case fantasy     // Fantasy story (kid-friendly, superhero/Keloğlan style)
    case dialogue    // Conversational dialogue
    
    var id: String { rawValue }
    
    /// Localized display name
    /// Keys: "story_type_motivation", "story_type_fantasy", "story_type_dialogue"
    var displayName: LocalizedStringKey {
        switch self {
        case .motivation:
            return "story_type_motivation"
        case .fantasy:
            return "story_type_fantasy"
        case .dialogue:
            return "story_type_dialogue"
        }
    }
    
    /// Emoji icon for UI
    var icon: String {
        switch self {
        case .motivation:
            return "💪"
        case .fantasy:
            return "🦸"  // Superhero
        case .dialogue:
            return "💬"
        }
    }
    
    /// Premium status for each type
    /// Only Fantasy requires premium
    var isPremium: Bool {
        switch self {
        case .fantasy:
            return true
        case .motivation, .dialogue:
            return false
        }
    }
    
    /// Instruction for AI prompt
    var promptInstruction: String {
        switch self {
        case .motivation:
            return "motivasyon ve ilham verici bir yazı yaz"
        case .fantasy:
            return "fantastik bir hikaye yaz (çocuklara uygun, süper kahraman veya Keloğlan tarzında telifsiz bir karakter kullan)"
        case .dialogue:
            return "günlük hayattan 2 kişinin karşılıklı konuştuğu bir diyalog yaz"
        }
    }
}
