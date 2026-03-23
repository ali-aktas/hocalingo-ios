//
//  MetaEventManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Added retention tracking (day 3, day 7) + paywall_viewed
//  ✅ Retention events fire automatically on app open — no manual calls needed
//  Location: Core/Utils/MetaEventManager.swift
//

import Foundation
import UIKit
import FBSDKCoreKit

// MARK: - App Delegate for Meta SDK
/// SwiftUI apps need a UIApplicationDelegate for Meta SDK to work
class MetaAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Meta SDK initialization — MUST happen here, not in SwiftUI init()
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        
        #if DEBUG
        Settings.shared.enableLoggingBehavior(.appEvents)
        Settings.shared.enableLoggingBehavior(.networkRequests)
        print("✅ Meta SDK initialized via AppDelegate + debug logging ON")
        #else
        print("✅ Meta SDK initialized via AppDelegate")
        #endif
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

// MARK: - Meta Event Manager
class MetaEventManager {
    static let shared = MetaEventManager()
    private init() {}
    
    // MARK: - Retention Tracking Keys
    private let installDateKey = "meta_install_date"
    private let day3FiredKey = "meta_day3_retention_fired"
    private let day7FiredKey = "meta_day7_retention_fired"
    
    // MARK: - App Activation
    
    /// Call when app becomes active (foreground)
    /// Also checks and fires retention events automatically
    func activateApp() {
        AppEvents.shared.activateApp()
        print("📊 Meta: App activated")
        
        // Track install date on first ever launch
        trackInstallDateIfNeeded()
        
        // Check retention milestones
        checkRetentionEvents()
    }
    
    /// Send a test event to verify SDK works
    func logTestEvent() {
        AppEvents.shared.logEvent(AppEvents.Name("test_event"))
        AppEvents.shared.flush()
        print("📊 Meta: test_event sent + flushed")
    }
    
    // MARK: - Funnel Events
    
    func logOnboardingStart() {
        AppEvents.shared.logEvent(AppEvents.Name("onboarding_start"))
        print("📊 Meta: onboarding_start")
    }
    
    func logOnboardingLevelSelected(level: String) {
        AppEvents.shared.logEvent(
            AppEvents.Name("onboarding_level_selected"),
            parameters: [AppEvents.ParameterName("level"): level]
        )
        print("📊 Meta: onboarding_level_selected → \(level)")
    }
    
    func logOnboardingCompleted() {
        AppEvents.shared.logEvent(.completedRegistration)
        print("📊 Meta: CompleteRegistration")
    }
    
    // MARK: - Engagement Events
    
    func logFirstWordSelectionCompleted(wordCount: Int) {
        AppEvents.shared.logEvent(
            AppEvents.Name("first_word_selection_completed"),
            parameters: [AppEvents.ParameterName("word_count"): wordCount]
        )
        print("📊 Meta: first_word_selection_completed → \(wordCount) words")
    }
    
    func logStudyCompleted(wordsStudied: Int, direction: String) {
        AppEvents.shared.logEvent(
            AppEvents.Name("lesson_completed"),
            parameters: [
                AppEvents.ParameterName("words_studied"): wordsStudied,
                AppEvents.ParameterName("direction"): direction
            ]
        )
        print("📊 Meta: lesson_completed → \(wordsStudied) words (\(direction))")
    }
    
    func logFirstStudyCompleted() {
        AppEvents.shared.logEvent(AppEvents.Name("first_study_completed"))
        print("📊 Meta: first_study_completed")
    }
    
    // MARK: - ✅ NEW: Paywall Event
    
    /// Track when paywall is displayed to the user
    /// Call this from PremiumPaywallView.onAppear
    func logPaywallViewed(trigger: String) {
        AppEvents.shared.logEvent(
            AppEvents.Name("paywall_viewed"),
            parameters: [AppEvents.ParameterName("trigger"): trigger]
        )
        print("📊 Meta: paywall_viewed (trigger: \(trigger))")
    }
    
    // MARK: - Monetization Events
    
    func logTrialStarted() {
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
        print("📊 Meta: StartTrial")
    }
    
    func logSubscriptionStarted(price: Double, currency: String = "TRY") {
        AppEvents.shared.logEvent(
            .purchased,
            valueToSum: price,
            parameters: [
                AppEvents.ParameterName.currency: currency
            ]
        )
        print("📊 Meta: Purchase → \(price) \(currency)")
    }
    
    // MARK: - ✅ NEW: Retention Tracking (Automatic)
    
    /// Record install date on first launch (called automatically from activateApp)
    private func trackInstallDateIfNeeded() {
        guard UserDefaults.standard.object(forKey: installDateKey) == nil else { return }
        UserDefaults.standard.set(Date(), forKey: installDateKey)
        print("📊 Meta: Install date recorded")
    }
    
    /// Check if day 3 or day 7 retention events should fire
    /// Each fires exactly once when the user opens the app on/after that day
    private func checkRetentionEvents() {
        guard let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date else { return }
        
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        
        // Day 3 retention (fires once, on or after day 3)
        if daysSinceInstall >= 3 && !UserDefaults.standard.bool(forKey: day3FiredKey) {
            AppEvents.shared.logEvent(AppEvents.Name("day_3_retention"))
            UserDefaults.standard.set(true, forKey: day3FiredKey)
            print("📊 Meta: day_3_retention ✅ (day \(daysSinceInstall))")
        }
        
        // Day 7 retention (fires once, on or after day 7)
        if daysSinceInstall >= 7 && !UserDefaults.standard.bool(forKey: day7FiredKey) {
            AppEvents.shared.logEvent(AppEvents.Name("day_7_retention"))
            UserDefaults.standard.set(true, forKey: day7FiredKey)
            print("📊 Meta: day_7_retention ✅ (day \(daysSinceInstall))")
        }
    }
}
