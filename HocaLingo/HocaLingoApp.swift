//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ UPDATED: Added RevenueCat integration for premium subscriptions
//  Created by Auralian on 15.01.2026.
//

import SwiftUI
import UserNotifications
import RevenueCat  // ✅ YENİ: RevenueCat import

@main
struct HocaLingoApp: App {
    
    // MARK: - Theme Management
    /// App-wide theme view model (singleton for consistent state)
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    // MARK: - Language Management
    /// App language stored in AppStorage for instant updates
    @AppStorage("app_language") private var appLanguageCode: String = UserDefaultsManager.shared.loadAppLanguage().rawValue
    
    // MARK: - Onboarding State
    /// Check if user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // MARK: - Initialization
    init() {
        // Set notification delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // ✅ YENİ: RevenueCat Configuration
        Purchases.logLevel = .debug  // Debug mode for testing
        Purchases.configure(withAPIKey: "appl_sfCiEYrSXxYYRRjbMFZOjwBfagG")
        
        print("✅ RevenueCat initialized")
    }
    
    // MARK: - Computed Properties
    
    /// Current app locale based on selected language
    private var currentLocale: Locale {
        Locale(identifier: appLanguageCode)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    // Main app
                    MainTabView()
                } else {
                    // Onboarding flow (first-time users)
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            // Apply theme globally to entire app
            .preferredColorScheme(themeViewModel.effectiveColorScheme)
            // Inject theme view model into environment
            .environment(\.themeViewModel, themeViewModel)
            // Apply locale for instant language change
            .environment(\.locale, currentLocale)
        }
    }
}
