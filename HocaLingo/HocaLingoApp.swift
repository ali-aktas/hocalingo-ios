//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ FIXED: Simplified - MainTabView takes no parameters
//  Location: HocaLingo/HocaLingoApp.swift
//

import SwiftUI
import UserNotifications
import RevenueCat

@main
struct HocaLingoApp: App {
    
    // MARK: - Theme Management
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    // MARK: - Language Management
    @AppStorage("app_language") private var appLanguageCode: String = UserDefaultsManager.shared.loadAppLanguage().rawValue
    
    // MARK: - Onboarding State
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // MARK: - Initialization
    init() {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // RevenueCat Configuration
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_sfCiEYrSXxYYRRjbMFZOjwBfagG")
        
        print("✅ RevenueCat initialized")
    }
    
    // MARK: - Computed Properties
    private var currentLocale: Locale {
        Locale(identifier: appLanguageCode)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    // ✅ FIXED: Main app without parameters
                    MainTabViewWrapper()
                } else {
                    // Onboarding flow
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .preferredColorScheme(themeViewModel.effectiveColorScheme)
            .environment(\.themeViewModel, themeViewModel)
            .environment(\.locale, currentLocale)
        }
    }
}

// MARK: - Main Tab View Wrapper (with First-Time Permission)
struct MainTabViewWrapper: View {
    @State private var hasRequestedNotificationPermission = false
    
    var body: some View {
        MainTabView()
            .onAppear {
                // ✅ NEW: Request notification permission on first launch (after onboarding)
                requestNotificationPermissionIfNeeded()
            }
    }
    
    // MARK: - First-Time Notification Permission
    private func requestNotificationPermissionIfNeeded() {
        // Only request once
        guard !hasRequestedNotificationPermission else { return }
        hasRequestedNotificationPermission = true
        
        // Small delay for better UX (after paywall might show)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            NotificationManager.shared.requestPermissionOnFirstLaunch { granted in
                if granted {
                    print("✅ Notifications auto-enabled on first launch")
                } else {
                    print("⚠️ User denied notification permission")
                }
            }
        }
    }
}
