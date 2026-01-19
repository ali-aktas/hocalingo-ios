//
//  AppLanguage.swift
//  HocaLingo
//
//  App language selection model
//  Location: HocaLingo/Models/AppLanguage.swift
//

import Foundation

// MARK: - App Language
/// Supported app languages for UI localization
/// Location: HocaLingo/Models/AppLanguage.swift
enum AppLanguage: String, Codable, CaseIterable {
    case turkish = "tr"
    case english = "en"
    
    // MARK: - Display Properties
    
    /// Display name in its own language (native name)
    var displayName: String {
        switch self {
        case .turkish:
            return "Türkçe"
        case .english:
            return "English"
        }
    }
    
    /// Display name with flag emoji
    var displayNameWithFlag: String {
        switch self {
        case .turkish:
            return "🇹🇷 Türkçe"
        case .english:
            return "🇬🇧 English"
        }
    }
    
    /// Language code for Localizable.strings (e.g., "tr", "en")
    var languageCode: String {
        return self.rawValue
    }
    
    /// Locale identifier for system locale (e.g., "tr_TR", "en_US")
    var localeIdentifier: String {
        switch self {
        case .turkish:
            return "tr_TR"
        case .english:
            return "en_US"
        }
    }
    
    // MARK: - System Default
    
    /// Detect system language and return matching AppLanguage
    /// Falls back to English if system language is not supported
    static var systemDefault: AppLanguage {
        let systemLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        // Check if system language matches any supported language
        for language in AppLanguage.allCases {
            if systemLanguageCode.hasPrefix(language.rawValue) {
                return language
            }
        }
        
        // Default to English if system language not supported
        return .english
    }
}
