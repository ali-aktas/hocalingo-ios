//
//  MetaEventManager.swift
//  HocaLingo
//
//  ✅ Meta (Facebook) App Events tracking for ad optimization
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
    
    // MARK: - App Activation
    
    /// Call when app becomes active (foreground)
    func activateApp() {
        AppEvents.shared.activateApp()
        print("📊 Meta: App activated")
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
}
