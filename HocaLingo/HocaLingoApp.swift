//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ UPDATED: Meta SDK via UIApplicationDelegateAdaptor
//  Location: HocaLingo/HocaLingoApp.swift
//

import SwiftUI
import UserNotifications
import RevenueCat
import FBSDKCoreKit

@main
struct HocaLingoApp: App {
    
    // MARK: - Meta SDK (MUST be first — initializes via AppDelegate)
    @UIApplicationDelegateAdaptor(MetaAppDelegate.self) var appDelegate
    
    // MARK: - Theme Management
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    // MARK: - Language Management
    @AppStorage("app_language") private var appLanguageCode: String = UserDefaultsManager.shared.loadAppLanguage().rawValue
    
    // MARK: - Onboarding State
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("hasCompletedFirstWordSelection") private var hasCompletedFirstWordSelection: Bool = false
    
    // MARK: - Scene Phase (Meta activate on foreground)
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Initialization
    init() {
        
        // Set initial language based on system language (runs only once on first launch)
        if UserDefaults.standard.string(forKey: "app_language") == nil {
            let defaultLanguage = AppLanguage.systemDefault.rawValue
            UserDefaults.standard.set(defaultLanguage, forKey: "app_language")
            print("🌍 Initial language set: \(defaultLanguage)")
        }
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // RevenueCat Configuration
        #if DEBUG
        Purchases.logLevel = .debug
        #else
        Purchases.logLevel = .error
        #endif
        
        Purchases.configure(withAPIKey: "appl_sfCiEYrSXxYYRRjbMFZOjwBfagG")
        print("✅ RevenueCat initialized")
        // Meta SDK is initialized via MetaAppDelegate — no code needed here
        
        // ✅ NEW: Mixpanel analytics
        MixpanelManager.shared.configure()
    }
    
    // MARK: - Computed Properties
    private var currentLocale: Locale {
        Locale(identifier: appLanguageCode)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                } else if !hasCompletedFirstWordSelection {
                    FirstWordSelectionView(hasCompletedFirstWordSelection: $hasCompletedFirstWordSelection)
                } else {
                    MainTabViewWrapper()
                }
            }
            .preferredColorScheme(themeViewModel.effectiveColorScheme)
            .environment(\.themeViewModel, themeViewModel)
            .environment(\.locale, currentLocale)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    MetaEventManager.shared.activateApp()
                
                }
            }
        }
    }
}

// MARK: - Main Tab View Wrapper (with First-Time Permission)
struct MainTabViewWrapper: View {
    @State private var hasRequestedNotificationPermission = false
    
    var body: some View {
        MainTabView()
            .onAppear {
                // CLEAR BADGE: Reset badge when app opens (iOS 17+)
                UNUserNotificationCenter.current().setBadgeCount(0) { error in
                    if let error = error {
                        print("❌ Badge clear error: \(error)")
                    }
                }
                
                // Request notification permission on first launch (after onboarding)
                requestNotificationPermissionIfNeeded()
                
                // ✅ NEW: Refresh daily notifications with fresh words on every app open
                NotificationManager.shared.refreshDailyRemindersIfNeeded()
            }
    }
    
    // MARK: - First-Time Notification Permission
    private func requestNotificationPermissionIfNeeded() {
        guard !hasRequestedNotificationPermission else { return }
        hasRequestedNotificationPermission = true
        
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
