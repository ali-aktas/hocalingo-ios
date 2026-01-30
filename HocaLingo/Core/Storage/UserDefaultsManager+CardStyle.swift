//
//  UserDefaultsManager+CardStyle.swift
//  HocaLingo
//
//  Card style preference management extension
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+CardStyle.swift
//

import Foundation

// MARK: - Card Style Management Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum CardStyleKeys {
        static let cardStyle = "card_style"
    }
    
    // MARK: - Card Style
    
    /// Save card style preference
    func saveCardStyle(_ style: CardStyle) {
        UserDefaults.standard.set(style.rawValue, forKey: CardStyleKeys.cardStyle)
        
        // Notify observers about card style change
        NotificationCenter.default.post(
            name: NSNotification.Name("CardStyleChanged"),
            object: nil
        )
        
        print("✅ Card style saved: \(style.displayName)")
    }
    
    /// Load card style preference
    /// Returns colorful (default) if no preference is saved
    func loadCardStyle() -> CardStyle {
        if let rawValue = UserDefaults.standard.string(forKey: CardStyleKeys.cardStyle),
           let style = CardStyle(rawValue: rawValue) {
            return style
        }
        
        // Return default style if no preference
        return .colorful
    }
}
