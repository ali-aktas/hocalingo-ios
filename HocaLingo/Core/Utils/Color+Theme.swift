//
//  Color+Theme.swift
//  HocaLingo
//
//  Theme-aware color system for light/dark mode support
//  Location: HocaLingo/Core/Utils/Color+Theme.swift
//

import SwiftUI

// MARK: - Theme Colors Extension
extension Color {
    
    // MARK: - Background Colors
    
    /// Main screen background - adapts to theme
    static var themeBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "0F0F0F"))  // Dark theme
                : UIColor(Color(hex: "F8F9FA"))  // Light theme
        })
    }
    
    /// Card background - adapts to theme
    static var themeCard: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "1C1C1E"))  // Dark theme
                : UIColor(Color(hex: "FFFFFF"))  // Light theme
        })
    }
    
    /// Secondary card background (slightly different shade)
    static var themeCardSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "2C2C2E"))  // Dark theme
                : UIColor(Color(hex: "F8F9FA"))  // Light theme
        })
    }
    
    // MARK: - Text Colors
    
    /// Primary text color - adapts to theme
    static var themePrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "FFFFFF"))  // Dark theme
                : UIColor(Color(hex: "000000"))  // Light theme
        })
    }
    
    /// Secondary text color - adapts to theme
    static var themeSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "9CA3AF"))  // Dark theme
                : UIColor(Color(hex: "6B7280"))  // Light theme
        })
    }
    
    /// Tertiary text color (very subtle)
    static var themeTertiary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "6B7280"))  // Dark theme
                : UIColor(Color(hex: "9CA3AF"))  // Light theme
        })
    }
    
    // MARK: - Divider & Border Colors
    
    /// Divider line color - adapts to theme
    static var themeDivider: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "2C2C2E"))  // Dark theme
                : UIColor(Color(hex: "E5E7EB"))  // Light theme
        })
    }
    
    /// Border color for cards
    static var themeBorder: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "3C3C3E"))  // Dark theme
                : UIColor(Color(hex: "E5E7EB"))  // Light theme
        })
    }
    
    // MARK: - Accent Colors (Brand - Static)
    
    /// HocaLingo brand teal - works in both themes
    static var accentTeal: Color {
        Color(hex: "4ECDC4")
    }
    
    /// Purple accent - works in both themes
    static var accentPurple: Color {
        Color(hex: "6366F1")
    }
    
    /// Orange accent - works in both themes
    static var accentOrange: Color {
        Color(hex: "F59E0B")
    }
    
    /// Green accent - works in both themes
    static var accentGreen: Color {
        Color(hex: "10B981")
    }
    
    // MARK: - Shadow Colors
    
    /// Shadow color - adapts to theme
    static var themeShadow: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.clear  // No shadow in dark mode
                : UIColor.black.withAlphaComponent(0.05)
        })
    }
    
    /// Strong shadow color
    static var themeShadowStrong: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.clear  // No shadow in dark mode
                : UIColor.black.withAlphaComponent(0.1)
        })
    }
}
