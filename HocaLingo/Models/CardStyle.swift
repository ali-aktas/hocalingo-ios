//
//  CardStyle.swift
//  HocaLingo
//
//  Card design style options for study cards
//  Location: HocaLingo/Models/CardStyle.swift
//

import Foundation

// MARK: - Card Style Enum
/// Study card design style options
/// ✅ 3 options: Colorful (default), Minimal (grey), Premium (gradient - Premium only)
enum CardStyle: String, Codable, CaseIterable {
    case colorful = "colorful"  // Default: Random vibrant colors
    case minimal = "minimal"     // Minimal: Single grey color
    case premium = "premium"     // Premium: Beautiful gradients (Premium users only)
    
    /// Display name for UI (localized)
    var displayName: String {
        switch self {
        case .colorful: return "card_style_colorful"
        case .minimal: return "card_style_minimal"
        case .premium: return "card_style_premium"
        }
    }
    
    /// Icon for UI
    var icon: String {
        switch self {
        case .colorful: return "paintpalette.fill"
        case .minimal: return "square.fill"
        case .premium: return "sparkles"
        }
    }
    
    /// Is this style premium-only?
    var requiresPremium: Bool {
        return self == .premium
    }
}
