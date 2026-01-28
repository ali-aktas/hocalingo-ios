//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ UPDATED: Added Notification Delegate for foreground support
//  Created by Auralian on 15.01.2026.
//

import SwiftUI
import UserNotifications

@main
struct HocaLingoApp: App {
    
    // MARK: - Theme Management
    /// App-wide theme view model (singleton for consistent state)
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    // MARK: - Language Management
    /// App language stored in AppStorage for instant updates
    /// @AppStorage automatically syncs with UserDefaults
    @AppStorage("app_language") private var appLanguageCode: String = UserDefaultsManager.shared.loadAppLanguage().rawValue
    
    // MARK: - Initialization
    init() {
        // Set notification delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    // MARK: - Computed Properties
    
    /// Current app locale based on selected language
    private var currentLocale: Locale {
        Locale(identifier: appLanguageCode)
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Apply theme globally to entire app
                .preferredColorScheme(themeViewModel.effectiveColorScheme)
                // Inject theme view model into environment
                .environment(\.themeViewModel, themeViewModel)
                // Apply locale for instant language change
                .environment(\.locale, currentLocale)
        }
    }
}
