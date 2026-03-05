//
//  MetaEventManager.swift
//  HocaLingo
//
//  ✅ NEW: Meta (Facebook) App Events tracking for ad optimization
//  Tracks user funnel: install → onboarding → word selection → study → purchase
//  Location: Core/Utils/MetaEventManager.swift
//

import Foundation
import FBSDKCoreKit

// MARK: - Meta Event Manager
/// Centralized Meta App Events tracker
/// All event names and parameters defined in one place
class MetaEventManager {
    static let shared = MetaEventManager()
    private init() {}
    
    // MARK: - SDK Initialization
    
    /// Call this once in HocaLingoApp.init()
    func configure() {
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        print("✅ Meta SDK configured")
    }
    
    /// Call this in app launch (activates app event automatically)
    func activateApp() {
        AppEvents.shared.activateApp()
        print("📊 Meta: App activated")
    }
    
    // MARK: - Funnel Events (Analytics)
    
    /// Onboarding started (user sees first screen)
    func logOnboardingStart() {
        AppEvents.shared.logEvent(AppEvents.Name("onboarding_start"))
        print("📊 Meta: onboarding_start")
    }
    
    /// Onboarding level selected (with level parameter)
    func logOnboardingLevelSelected(level: String) {
        AppEvents.shared.logEvent(
            AppEvents.Name("onboarding_level_selected"),
            parameters: [AppEvents.ParameterName("level"): level]
        )
        print("📊 Meta: onboarding_level_selected → \(level)")
    }
    
    /// Onboarding completed (standard Meta event)
    func logOnboardingCompleted() {
        AppEvents.shared.logEvent(.completedRegistration)
        print("📊 Meta: CompleteRegistration (onboarding done)")
    }
    
    // MARK: - Engagement Events
    
    /// First word selection completed (with count)
    func logFirstWordSelectionCompleted(wordCount: Int) {
        AppEvents.shared.logEvent(
            AppEvents.Name("first_word_selection_completed"),
            parameters: [AppEvents.ParameterName("word_count"): wordCount]
        )
        print("📊 Meta: first_word_selection_completed → \(wordCount) words")
    }
    
    /// Study session completed (lesson_completed)
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
    
    /// First ever study session
    func logFirstStudyCompleted() {
        AppEvents.shared.logEvent(AppEvents.Name("first_study_completed"))
        print("📊 Meta: first_study_completed")
    }
    
    // MARK: - Monetization Events
    
    /// Trial started (if you add free trial later)
    func logTrialStarted() {
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
        print("📊 Meta: StartTrial")
    }
    
    /// Premium subscription purchased
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
