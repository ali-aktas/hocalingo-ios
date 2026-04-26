//
//  HardWordsQuizLimitManager.swift
//  HocaLingo
//
//  ✅ NEW: Lifetime free-trial system for Hard Words Quiz premium feature
//  Free users get 3 full quiz sessions, then paywalled.
//  Home nudge banner fires every 5 new hard words (until user tries the quiz).
//  Location: HocaLingo/Core/Utils/HardWordsQuizLimitManager.swift
//

import Foundation
import Combine

// MARK: - Hard Words Quiz Limit Manager
/// Singleton that governs free-tier access to the Hard Words Quiz.
///
/// Strategy:
///  • Free users get **3 lifetime quiz sessions** — full experience, no content gating.
///  • After 3 sessions, tapping the "Hard Words" button routes to the paywall.
///  • A Home-screen nudge fires at every +5 hard-word milestone (5, 10, 15, …)
///    but ONLY if the user has not yet tried the feature (quizSessionsUsed == 0).
///  • The banner can be dismissed; dismissal sets the threshold forward so the
///    next banner appears at the next +5 milestone.
///
/// Counters are mirrored to @Published properties so SwiftUI can react.
final class HardWordsQuizLimitManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = HardWordsQuizLimitManager()
    
    // MARK: - Constants
    /// Total free quiz sessions available over the user's lifetime.
    static let freeSessionLimit: Int = 3
    
    /// Hard-word count step that triggers the Home nudge banner.
    static let nudgeMilestone: Int = 5
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let sessionsUsed          = "hardwords_quiz_sessions_used"
        static let lastNudgeDismissedAt  = "hardwords_quiz_nudge_dismissed_at_count"
    }
    
    // MARK: - Published (drive SwiftUI)
    /// Number of quiz sessions completed by a free user. Capped display at freeSessionLimit.
    @Published private(set) var sessionsUsed: Int = 0
    
    // MARK: - Private
    private let defaults = UserDefaults.standard
    
    // MARK: - Init
    private init() {
        self.sessionsUsed = defaults.integer(forKey: Keys.sessionsUsed)
        
        #if DEBUG
        print("🎯 HardWordsQuizLimit init → sessionsUsed=\(sessionsUsed), limit=\(Self.freeSessionLimit)")
        #endif
    }
    
    // MARK: - Access Checks
    
    /// Whether the user may start a new quiz session right now.
    /// Premium users always pass. Free users pass if they have sessions remaining.
    var canStartQuiz: Bool {
        if PremiumManager.shared.isPremium { return true }
        return sessionsUsed < Self.freeSessionLimit
    }
    
    /// Remaining free sessions — relevant only for free users.
    /// Returns 0 for premium (they don't need this number) and when limit exhausted.
    var remainingFreeSessions: Int {
        guard !PremiumManager.shared.isPremium else { return 0 }
        return max(0, Self.freeSessionLimit - sessionsUsed)
    }
    
    /// True only for free users who have already consumed all free sessions.
    /// Used by Vault to route flame-button taps straight to the paywall.
    var isFreeLimitExhausted: Bool {
        !PremiumManager.shared.isPremium && sessionsUsed >= Self.freeSessionLimit
    }
    
    /// True only for free users who have not yet used any free session.
    /// Used by Home nudge banner — we don't want to nag users who already know the feature.
    var isFirstTimeFreeUser: Bool {
        !PremiumManager.shared.isPremium && sessionsUsed == 0
    }
    
    // MARK: - Session Tracking
    
    /// Call this EXACTLY ONCE when a free user's quiz session completes.
    /// Premium sessions are never counted (no-op).
    func recordSessionCompletedIfFree() {
        guard !PremiumManager.shared.isPremium else { return }
        
        let newCount = sessionsUsed + 1
        sessionsUsed = newCount
        defaults.set(newCount, forKey: Keys.sessionsUsed)
        
        #if DEBUG
        print("🎯 Free quiz session completed → used=\(newCount)/\(Self.freeSessionLimit)")
        #endif
    }
    
    // MARK: - Nudge Banner Logic
    
    /// Whether the Home-screen nudge banner should currently be visible.
    /// - Parameter hardWordsCount: live count of words with 5+ hard presses.
    ///
    /// Visible when ALL of:
    ///   - User is free (not premium)
    ///   - User has never tried the quiz yet (sessionsUsed == 0)
    ///   - hardWordsCount has crossed the next +5 milestone since last dismissal
    func shouldShowNudge(for hardWordsCount: Int) -> Bool {
        // Premium users and free users who have already tasted the feature: no nudge.
        guard isFirstTimeFreeUser else { return false }
        
        // Below the first milestone: no nudge yet.
        guard hardWordsCount >= Self.nudgeMilestone else { return false }
        
        // Compute the milestone floor for the current count (5 → 5, 7 → 5, 11 → 10, …).
        let currentMilestone = (hardWordsCount / Self.nudgeMilestone) * Self.nudgeMilestone
        
        // Last dismissed milestone (0 if never dismissed).
        let lastDismissed = defaults.integer(forKey: Keys.lastNudgeDismissedAt)
        
        return currentMilestone > lastDismissed
    }
    
    /// Call when the user taps the banner's close (X) button.
    /// Suppresses the banner until the NEXT +5 milestone is crossed.
    func dismissNudge(at hardWordsCount: Int) {
        let currentMilestone = (hardWordsCount / Self.nudgeMilestone) * Self.nudgeMilestone
        defaults.set(currentMilestone, forKey: Keys.lastNudgeDismissedAt)
        
        #if DEBUG
        print("🎯 Nudge dismissed at milestone=\(currentMilestone)")
        #endif
    }
    
    // MARK: - Debug / Testing
    
    /// Reset all free-trial state (debug only — hook up behind a Profile debug menu if needed).
    #if DEBUG
    func resetAllForDebug() {
        sessionsUsed = 0
        defaults.removeObject(forKey: Keys.sessionsUsed)
        defaults.removeObject(forKey: Keys.lastNudgeDismissedAt)
        print("🔄 HardWordsQuizLimit fully reset")
    }
    #endif
}
