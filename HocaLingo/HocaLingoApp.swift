//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ MAJOR UPDATE: Instant language change with @AppStorage auto-sync
//  Created by Auralian on 15.01.2026.
//

import SwiftUI

@main
struct HocaLingoApp: App {
    
    // MARK: - Theme Management
    /// App-wide theme view model (singleton for consistent state)
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    // MARK: - Language Management
    /// App language stored in AppStorage for instant updates
    /// ✅ CRITICAL: @AppStorage automatically syncs with UserDefaults
    /// When ProfileViewModel updates UserDefaults, @AppStorage detects it and triggers UI refresh
    @AppStorage("app_language") private var appLanguageCode: String = UserDefaultsManager.shared.loadAppLanguage().rawValue
    
    // MARK: - Computed Properties
    
    /// Current app locale based on selected language
    private var currentLocale: Locale {
        Locale(identifier: appLanguageCode == "tr" ? "tr_TR" : "en_US")
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // ✅ Apply theme globally to entire app
                .preferredColorScheme(themeViewModel.effectiveColorScheme)
                // ✅ Inject theme view model into environment
                .environment(\.themeViewModel, themeViewModel)
                // ✅ CRITICAL: Apply locale for instant language change
                // @AppStorage monitors UserDefaults - when it changes, this rebuilds
                .environment(\.locale, currentLocale)
        }
    }
}
