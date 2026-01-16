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
        Color(hex: "FFE5E5"),  // Light pink
        Color(hex: "E1F5FE"),  // Light blue
        Color(hex: "FFF3E0"),  // Light orange
        Color(hex: "F3E5F5"),  // Light purple
        Color(hex: "E8F5E9"),  // Light green
        Color(hex: "FFF9C4"),  // Light yellow
        Color(hex: "FCE4EC"),  // Light rose
        Color(hex: "E0F2F1"),  // Light teal
        Color(hex: "FFF8E1"),  // Light amber
        Color(hex: "F1F8E9"),  // Light lime
        Color(hex: "E8EAF6"),  // Light indigo
        Color(hex: "FBE9E7"),  // Light deep orange
        Color(hex: "ECEFF1"),  // Light blue grey
        Color(hex: "F9FBE7"),  // Light lime green
        Color(hex: "E3F2FD"),  // Pale blue
        Color(hex: "FFF3E0"),  // Pale peach
        Color(hex: "E1BEE7"),  // Pale lavender
        Color(hex: "C8E6C9"),  // Pale green
        Color(hex: "FFE082"),  // Pale gold
        Color(hex: "FFCCBC"),  // Pale coral
        Color(hex: "B2EBF2"),  // Pale cyan
        Color(hex: "F0F4C3"),  // Pale yellow-green
        Color(hex: "D1C4E9"),  // Pale purple
        Color(hex: "FFAB91"),  // Pale orange
        Color(hex: "CFD8DC"),  // Pale grey-blue
        Color(hex: "DCEDC8"),  // Pale lime
        Color(hex: "BBDEFB"),  // Pale sky blue
        Color(hex: "FFE0B2"),  // Pale apricot
        Color(hex: "C5CAE9"),  // Pale periwinkle
        Color(hex: "B2DFDB")   // Pale mint
    ]
    
    /// Get pastel color by index
    /// - Parameter index: Card index or word ID
    /// - Returns: Pastel color from the palette
    static func pastelColor(for index: Int) -> Color {
        return pastelColors[index % pastelColors.count]
    }
}
