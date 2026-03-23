//
//  MixpanelManager.swift
//  HocaLingo
//
//  ✅ NEW: Mixpanel product analytics manager
//  Tracks: Funnel, Engagement, Retention, Milestones
//  SDK: https://github.com/mixpanel/mixpanel-swift (add via SPM)
//  Location: Core/Utils/MixpanelManager.swift
//

import Foundation
import Mixpanel

// MARK: - Mixpanel Manager
class MixpanelManager {
    static let shared = MixpanelManager()
    private init() {}
    
    // MARK: - Configuration
    
    /// Initialize Mixpanel — call once from HocaLingoApp.init()
    /// Replace "YOUR_MIXPANEL_TOKEN" with your actual project token
    func configure() {
        Mixpanel.initialize(token: "f3bda699b1f19176c408fb689816d2c9", trackAutomaticEvents: false, serverURL: "https://api-eu.mixpanel.com")
        
        #if DEBUG
        Mixpanel.mainInstance().loggingEnabled = true
        print("✅ Mixpanel initialized (debug mode)")
        #else
        print("✅ Mixpanel initialized")
        #endif
        
        // Set initial super properties (sent with every event)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        
        Mixpanel.mainInstance().registerSuperProperties([
            "app_version": appVersion,
            "build_number": buildNumber,
            "platform": "iOS"
        ])
    }
    
    // MARK: - User Identity
    
    /// Set user properties for cohort analysis
    /// Call after onboarding and when values change
    func setUserProperties(
        level: String? = nil,
        language: String? = nil,
        isPremium: Bool? = nil,
        totalWordsSelected: Int? = nil,
        studyDirection: String? = nil
    ) {
        var properties: Properties = [:]
        
        if let level = level { properties["english_level"] = level }
        if let language = language { properties["app_language"] = language }
        if let isPremium = isPremium { properties["is_premium"] = isPremium }
        if let totalWordsSelected = totalWordsSelected { properties["total_words_selected"] = totalWordsSelected }
        if let studyDirection = studyDirection { properties["study_direction"] = studyDirection }
        
        Mixpanel.mainInstance().people.set(properties: properties)
    }
    
    // =========================================================================
    // MARK: - FUNNEL EVENTS (User Journey)
    // =========================================================================
    
    // MARK: App Open
    
    /// Track every app open with context
    /// Call from MainTabView.onAppear or scenePhase change
    func trackAppOpened() {
        let installDate = UserDefaults.standard.object(forKey: "meta_install_date") as? Date ?? Date()
        let dayNumber = (Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0) + 1
        let totalOpens = UserDefaults.standard.integer(forKey: "mx_total_app_opens") + 1
        UserDefaults.standard.set(totalOpens, forKey: "mx_total_app_opens")
        
        Mixpanel.mainInstance().track(event: "app_opened", properties: [
            "day_number": dayNumber,
            "total_opens": totalOpens
        ])
    }
    
    // MARK: Onboarding
    
    func trackOnboardingStarted() {
        Mixpanel.mainInstance().track(event: "onboarding_started")
    }
    
    func trackOnboardingStepCompleted(step: String, selection: String? = nil) {
        var props: Properties = ["step": step]
        if let selection = selection { props["selection"] = selection }
        Mixpanel.mainInstance().track(event: "onboarding_step_completed", properties: props)
    }
    
    func trackOnboardingSkipped(atStep: String) {
        Mixpanel.mainInstance().track(event: "onboarding_skipped", properties: [
            "skipped_at_step": atStep
        ])
    }
    
    func trackOnboardingCompleted(level: String, goal: String) {
        Mixpanel.mainInstance().track(event: "onboarding_completed", properties: [
            "selected_level": level,
            "selected_goal": goal
        ])
        
        // Set user profile
        setUserProperties(level: level)
        Mixpanel.mainInstance().people.set(properties: ["onboarding_completed_at": Date().iso8601String])
    }
    
    // MARK: Word Selection
    
    func trackWordSelectionStarted(packageId: String) {
        Mixpanel.mainInstance().track(event: "word_selection_started", properties: [
            "package_id": packageId
        ])
    }
    
    func trackWordSelectionCompleted(packageId: String, wordsSelected: Int, wordsSkipped: Int) {
        Mixpanel.mainInstance().track(event: "word_selection_completed", properties: [
            "package_id": packageId,
            "words_selected": wordsSelected,
            "words_skipped": wordsSkipped
        ])
        
        // Update user profile
        Mixpanel.mainInstance().people.increment(property: "total_words_selected", by: Double(wordsSelected))
    }
    
    // MARK: Study Sessions
    
    func trackStudySessionStarted(direction: String, queueSize: Int) {
        Mixpanel.mainInstance().track(event: "study_session_started", properties: [
            "direction": direction,
            "queue_size": queueSize
        ])
    }
    
    func trackStudySessionCompleted(cardsCompleted: Int, direction: String) {
        Mixpanel.mainInstance().track(event: "study_session_completed", properties: [
            "cards_completed": cardsCompleted,
            "direction": direction
        ])
        
        // Increment lifetime counters
        Mixpanel.mainInstance().people.increment(property: "total_sessions", by: 1)
        Mixpanel.mainInstance().people.increment(property: "total_cards_studied", by: Double(cardsCompleted))
        
        // Check milestones
        checkSessionMilestone()
    }
    
    func trackCardAnswered(difficulty: String, wordId: Int, isLearningPhase: Bool) {
        Mixpanel.mainInstance().track(event: "card_answered", properties: [
            "difficulty": difficulty,
            "word_id": wordId,
            "is_learning_phase": isLearningPhase
        ])
    }
    
    // =========================================================================
    // MARK: - ENGAGEMENT EVENTS (Feature Usage)
    // =========================================================================
    
    // MARK: Paywall
    
    func trackPaywallViewed(trigger: String) {
        Mixpanel.mainInstance().track(event: "paywall_viewed", properties: [
            "trigger": trigger
        ])
    }
    
    func trackPaywallDismissed(trigger: String) {
        Mixpanel.mainInstance().track(event: "paywall_dismissed", properties: [
            "trigger": trigger
        ])
    }
    
    func trackSubscriptionStarted(plan: String, price: Double, currency: String) {
        Mixpanel.mainInstance().track(event: "subscription_started", properties: [
            "plan": plan,
            "price": price,
            "currency": currency
        ])
        
        // Update user profile
        setUserProperties(isPremium: true)
        Mixpanel.mainInstance().people.set(properties: ["first_purchase_date": Date().iso8601String])
    }
    
    // MARK: AI Story
    
    func trackAIStoryGenerated(wordCount: Int) {
        Mixpanel.mainInstance().track(event: "ai_story_generated", properties: [
            "word_count": wordCount
        ])
        Mixpanel.mainInstance().people.increment(property: "total_stories_generated", by: 1)
    }
    
    // MARK: Package Browsing
    
    func trackPackageOpened(packageId: String, isPremium: Bool) {
        Mixpanel.mainInstance().track(event: "package_opened", properties: [
            "package_id": packageId,
            "is_premium": isPremium
        ])
    }
    
    // MARK: Notification
    
    func trackNotificationTapped(destination: String) {
        Mixpanel.mainInstance().track(event: "notification_tapped", properties: [
            "destination": destination
        ])
    }
    
    // MARK: Settings Changes
    
    func trackSettingChanged(setting: String, newValue: String) {
        Mixpanel.mainInstance().track(event: "setting_changed", properties: [
            "setting": setting,
            "new_value": newValue
        ])
    }
    
    // =========================================================================
    // MARK: - MILESTONE EVENTS (Quality Signals)
    // =========================================================================
    
    /// Check and fire word graduation milestones (10, 25, 50, 100, 250, 500)
    /// Call after a word graduates from learning to review phase
    func checkWordGraduationMilestone(totalGraduated: Int) {
        let milestones = [10, 25, 50, 100, 250, 500]
        
        for milestone in milestones {
            let key = "mx_milestone_words_\(milestone)"
            if totalGraduated >= milestone && !UserDefaults.standard.bool(forKey: key) {
                UserDefaults.standard.set(true, forKey: key)
                
                Mixpanel.mainInstance().track(event: "words_graduated_milestone", properties: [
                    "milestone": milestone,
                    "actual_count": totalGraduated
                ])
                print("🎯 Mixpanel: words_graduated_milestone → \(milestone)")
            }
        }
    }
    
    /// Check session count milestones
    private func checkSessionMilestone() {
        let totalSessions = UserDefaults.standard.integer(forKey: "mx_total_sessions") + 1
        UserDefaults.standard.set(totalSessions, forKey: "mx_total_sessions")
        
        let milestones = [5, 10, 25, 50, 100]
        
        for milestone in milestones {
            let key = "mx_milestone_sessions_\(milestone)"
            if totalSessions >= milestone && !UserDefaults.standard.bool(forKey: key) {
                UserDefaults.standard.set(true, forKey: key)
                
                Mixpanel.mainInstance().track(event: "study_sessions_milestone", properties: [
                    "milestone": milestone
                ])
                print("🎯 Mixpanel: study_sessions_milestone → \(milestone)")
            }
        }
    }
    
    // =========================================================================
    // MARK: - DAY STREAK TRACKING
    // =========================================================================
    
    /// Track consecutive study days and fire streak milestones
    /// Call when a study session is completed
    func trackDayStreak() {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let lastStudyDate = UserDefaults.standard.string(forKey: "mx_last_study_date") ?? ""
        
        if today == lastStudyDate { return } // Already tracked today
        
        let yesterday = DateFormatter.yyyyMMdd.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        var currentStreak = UserDefaults.standard.integer(forKey: "mx_current_streak")
        
        if lastStudyDate == yesterday {
            currentStreak += 1 // Consecutive day
        } else {
            currentStreak = 1 // Streak broken, restart
        }
        
        UserDefaults.standard.set(today, forKey: "mx_last_study_date")
        UserDefaults.standard.set(currentStreak, forKey: "mx_current_streak")
        
        // Update user profile
        Mixpanel.mainInstance().people.set(properties: ["current_streak": currentStreak])
        
        // Fire streak milestones
        let streakMilestones = [3, 7, 14, 30, 60]
        for milestone in streakMilestones {
            let key = "mx_streak_milestone_\(milestone)"
            if currentStreak >= milestone && !UserDefaults.standard.bool(forKey: key) {
                UserDefaults.standard.set(true, forKey: key)
                
                Mixpanel.mainInstance().track(event: "day_streak_milestone", properties: [
                    "streak_days": milestone
                ])
                print("🔥 Mixpanel: day_streak_milestone → \(milestone) days")
            }
        }
    }
}

// MARK: - Date Helpers

private extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: self)
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()
}
