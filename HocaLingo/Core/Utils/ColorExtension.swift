//
//  ColorExtension.swift
//  HocaLingo
//
//  ✅ UPDATED: Added 30 pastel colors for random card colors
//  Location: HocaLingo/Core/Utils/ColorExtension.swift
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "FF5733", "#FF5733", "F57")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// ✅ NEW: 30 random pastel colors for study cards
    /// Each card gets a color based on: index % 30
    static let pastelColors: [Color] = [
        Color(hex: "FDE2E4"), // Soft blush
        Color(hex: "DCEEFE"), // Powder blue
        Color(hex: "FFE8D6"), // Soft peach
        Color(hex: "EADCF8"), // Soft lavender
        Color(hex: "DFF7E3"), // Mint green
        Color(hex: "FFF4CC"), // Cream yellow
        Color(hex: "FAD2E1"), // Rosy pink
        Color(hex: "D7F3F0"), // Aqua mist
        Color(hex: "FCEFE3"), // Light sand
        Color(hex: "E6F4EA"), // Fresh light green
        Color(hex: "E3E8FF"), // Periwinkle light
        Color(hex: "FFE2DD"), // Soft coral blush
        Color(hex: "EEF1F7"), // Cool light grey
        Color(hex: "F4FCE9"), // Soft lime milk
        Color(hex: "E6F2FF"), // Ice blue
        Color(hex: "FFF1E6"), // Apricot cream
        Color(hex: "E9D8FD"), // Lilac pastel
        Color(hex: "D8F3DC"), // Soft meadow
        Color(hex: "FFF6E0"), // Vanilla pastel
        Color(hex: "FFDCDC"), // Pale watermelon
        Color(hex: "D0F0FD"), // Light cyan cloud
        Color(hex: "F7F9D9"), // Light pistachio
        Color(hex: "E4D9FF"), // Misty violet
        Color(hex: "FFD8BE"), // Soft apricot
        Color(hex: "E7EDF3"), // Modern fog grey
        Color(hex: "EAF7E1"), // Spring light
        Color(hex: "DCEBFF"), // Sky milk
        Color(hex: "FFEBD6"), // Peach cream
        Color(hex: "DCD6F7"), // Soft indigo haze
        Color(hex: "D6F5F0")  // Pastel turquoise
    ]
    
    /// Get pastel color by index
    /// - Parameter index: Card index or word ID
    /// - Returns: Pastel color from the palette
    static func pastelColor(for index: Int) -> Color {
        return pastelColors[index % pastelColors.count]
    }
}
