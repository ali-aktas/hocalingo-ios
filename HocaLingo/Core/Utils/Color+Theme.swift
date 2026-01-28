//
//  Color+Theme.swift
//  HocaLingo
//
//  ✅ UPDATED: Modern background colors for better aesthetics
//  Dark mode: #0A0A0B (Modern dark grey-black)
//  Light mode: #F8F8F7 (Warm off-white/cream)
//
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
                ? UIColor(Color(hex: "0A0A0B"))  // Dark theme - Modern dark grey-black
                : UIColor(Color(hex: "F8F8F7"))  // Light theme - Warm off-white (cream)
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
    
    // MARK: - ✅ NEW: Dynamic Button Colors (Light/Dark Mode)
    
    /// Primary button color - adapts to theme
    /// Light mode: Orange (FB9322)
    /// Dark mode: Purple (9333EA)
    static var themePrimaryButton: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "9333EA"))  // Dark mode: Purple
                : UIColor(Color(hex: "FB9322"))  // Light mode: Orange
        })
    }
    
    /// Primary button gradient start - adapts to theme
    static var themePrimaryButtonGradientStart: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "9333EA"))  // Dark mode: Purple
                : UIColor(Color(hex: "FB9322"))  // Light mode: Orange
        })
    }
    
    /// Primary button gradient end - adapts to theme
    static var themePrimaryButtonGradientEnd: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(Color(hex: "7C3AED"))  // Dark mode: Darker Purple
                : UIColor(Color(hex: "FF6B00"))  // Light mode: Darker Orange
        })
    }
    
    /// Primary button shadow color - adapts to theme
    static var themePrimaryButtonShadow: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                // Dark mode: Purple shadow with alpha
                return UIColor(red: 147/255, green: 51/255, blue: 234/255, alpha: 0.4)
            } else {
                // Light mode: Orange shadow with alpha
                return UIColor(red: 251/255, green: 147/255, blue: 34/255, alpha: 0.4)
            }
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
