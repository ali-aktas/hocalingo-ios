//
//  UserDefaultsManager+Language.swift
//  HocaLingo
//
//  App language management extension
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+Language.swift
//

import Foundation

// MARK: - Language Management Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum LanguageKeys {
        static let appLanguage = "app_language"
    }
    
    // MARK: - App Language
    
    /// Save app language preference
    func saveAppLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set(language.rawValue, forKey: LanguageKeys.appLanguage)
        
        // Apply language change to app
        applyLanguageChange(language)
        
        print("✅ App language saved: \(language.displayName)")
    }
    
    /// Load app language preference
    /// Returns system default if no preference is saved
    func loadAppLanguage() -> AppLanguage {
        if let rawValue = UserDefaults.standard.string(forKey: LanguageKeys.appLanguage),
           let language = AppLanguage(rawValue: rawValue) {
            return language
        }
        
        // Return system default if no preference
        return AppLanguage.systemDefault
    }
    
    // MARK: - Language Application
    
    /// Apply language change to the app
    /// This sets the app's locale and updates UserDefaults
    private func applyLanguageChange(_ language: AppLanguage) {
        // Set user defaults for app language
        UserDefaults.standard.set([language.languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        print("✅ Language applied: \(language.languageCode)")
        print("⚠️ Note: App restart required for full language change")
    }
    
    /// Check if app needs restart for language change
    /// Returns true if selected language differs from current UI language
    func needsRestartForLanguageChange(_ newLanguage: AppLanguage) -> Bool {
        let currentLanguage = loadAppLanguage()
        return currentLanguage != newLanguage
    }
}
