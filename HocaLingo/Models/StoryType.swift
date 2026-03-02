//
//  StoryType.swift
//  HocaLingo
//
//  AI Story Generation - Story Type Enum
//  ✅ REDESIGNED: SF Symbols replace emojis
//  Location: HocaLingo/Models/StoryType.swift
//

import Foundation
import SwiftUI

/// Story type classification
/// Defines the style and format of generated stories
/// ✅ REDESIGNED: Emojis replaced with SF Symbols
enum StoryType: String, Codable, CaseIterable, Identifiable {
    case motivation  // Motivational/inspirational content
    case fantasy     // Fantasy story with original characters
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
    
    /// ✅ SF Symbol icon name (replaces emoji)
    var iconName: String {
        switch self {
        case .motivation:
            return "flame.fill"
        case .fantasy:
            return "wand.and.stars"
        case .dialogue:
            return "bubble.left.and.bubble.right.fill"
        }
    }
    
    /// ✅ DEPRECATED: Old emoji icon - now returns SF Symbol name for compatibility
    /// Views should use iconName instead
    var icon: String {
        return iconName
    }
    
    /// Icon color for UI
    var iconColor: Color {
        switch self {
        case .motivation:
            return Color(hex: "F59E0B")  // Amber
        case .fantasy:
            return Color(hex: "8B5CF6")  // Purple
        case .dialogue:
            return Color(hex: "3B82F6")  // Blue
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
    /// ✅ FIXED: Fantasy creates ORIGINAL characters
    var promptInstruction: String {
        switch self {
        case .motivation:
            return "motivasyon ve ilham verici bir yazı yaz"
        case .fantasy:
            return """
            tamamen ORİJİNAL bir fantastik hikaye yaz.
            
            KARAKTER KURALLARI:
            - TAMAMEN YENİ bir karakter yarat (isim, kişilik, güçler)
            - Mevcut hiçbir karakteri kullanma (Keloğlan, Nasrettin Hoca vs. YASAK)
            - Yaratıcı ol: süper güçleri olan, konuşan hayvanlar, büyülü varlıklar olabilir
            - Çocuklara uygun, ilham verici bir kahraman olmalı
            
            HİKAYE ELEMANLARI:
            - Büyülü bir dünya veya olağanüstü olaylar
            - Macera ve keşif
            - İyi vs kötü temelli değil, öğretici olmalı
            - Çocukların hayal gücünü geliştirmeli
            """
        case .dialogue:
            return "günlük hayattan 2 kişinin karşılıklı konuştuğu bir diyalog yaz"
        }
    }
}
