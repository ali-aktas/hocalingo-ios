//
//  WeeklySelectionLimitManager.swift
//  HocaLingo
//
//  ✅ NEW: Replaces DailySelectionLimitManager
//  Free users: 50 selections per week
//  Premium users: Unlimited, soft warning at 100/week
//  Week resets every Monday at 00:00
//  Location: Core/Utils/WeeklySelectionLimitManager.swift
//

import Foundation

class WeeklySelectionLimitManager {
    static let shared = WeeklySelectionLimitManager()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Limits
    private let freeWeeklyLimit = 50
    private let premiumSoftWarningLimit = 100
    
    // MARK: - Keys
    private let selectionsCountKey = "weekly_selections_count"
    private let weekStartDateKey = "weekly_selections_week_start"
    
    private init() {
        checkAndResetIfNeeded()
    }
    
    // MARK: - Premium Check
    var isPremium: Bool {
        return PremiumManager.shared.isPremium
    }
    
    // MARK: - Week Reset Logic
    
    /// Returns the start of the current week (Monday 00:00)
    private func currentWeekStart() -> Date {
        let calendar = Calendar(identifier: .iso8601) // Monday = first day
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        return calendar.date(from: components) ?? Date()
    }
    
    private func checkAndResetIfNeeded() {
        let currentStart = currentWeekStart()
        
        if let savedStart = userDefaults.object(forKey: weekStartDateKey) as? Date {
            // If saved week start is before current week start → new week, reset
            if savedStart < currentStart {
                resetCounter(weekStart: currentStart)
            }
        } else {
            // First time — initialize
            userDefaults.set(currentStart, forKey: weekStartDateKey)
        }
    }
    
    private func resetCounter(weekStart: Date) {
        userDefaults.set(0, forKey: selectionsCountKey)
        userDefaults.set(weekStart, forKey: weekStartDateKey)
        print("🔄 Weekly selection counter reset (new week)")
    }
    
    // MARK: - Public API
    
    /// Can the user select another word?
    func canSelect() -> Bool {
        checkAndResetIfNeeded()
        
        if isPremium { return true }
        
        let currentCount = userDefaults.integer(forKey: selectionsCountKey)
        return currentCount < freeWeeklyLimit
    }
    
    /// Record a selection. Returns remaining count (nil for premium).
    @discardableResult
    func recordSelection() -> Int? {
        checkAndResetIfNeeded()
        
        var currentCount = userDefaults.integer(forKey: selectionsCountKey)
        currentCount += 1
        userDefaults.set(currentCount, forKey: selectionsCountKey)
        
        if isPremium {
            print("✅ Premium selection recorded: \(currentCount) this week")
            return nil
        }
        
        let remaining = freeWeeklyLimit - currentCount
        print("✅ Selection recorded: \(currentCount)/\(freeWeeklyLimit) this week")
        return max(0, remaining)
    }
    
    /// Undo a selection (for swipe undo feature)
    func undoSelection() {
        checkAndResetIfNeeded()
        
        var currentCount = userDefaults.integer(forKey: selectionsCountKey)
        currentCount = max(0, currentCount - 1)
        userDefaults.set(currentCount, forKey: selectionsCountKey)
        
        print("↩️ Selection undone: \(currentCount)/\(freeWeeklyLimit) this week")
    }
    
    /// Get remaining selections for free users
    func getRemainingSelections() -> Int {
        checkAndResetIfNeeded()
        
        if isPremium { return Int.max }
        
        let currentCount = userDefaults.integer(forKey: selectionsCountKey)
        return max(0, freeWeeklyLimit - currentCount)
    }
    
    /// Current count this week
    func getCurrentCount() -> Int {
        checkAndResetIfNeeded()
        return userDefaults.integer(forKey: selectionsCountKey)
    }
    
    /// Should show warning banner? (free: last 10, premium: at 100)
    func shouldShowWarning() -> Bool {
        checkAndResetIfNeeded()
        let currentCount = userDefaults.integer(forKey: selectionsCountKey)
        
        if isPremium {
            return currentCount >= premiumSoftWarningLimit
        }
        
        let remaining = freeWeeklyLimit - currentCount
        return remaining <= 10 && remaining > 0
    }
    
    /// Should show premium soft warning? (premium users at 100+ words/week)
    func shouldShowPremiumSoftWarning() -> Bool {
        guard isPremium else { return false }
        return getCurrentCount() >= premiumSoftWarningLimit
    }
    
    /// Days until weekly reset (for UI messaging)
    func daysUntilReset() -> Int {
        let calendar = Calendar(identifier: .iso8601)
        let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart()) ?? Date()
        let days = calendar.dateComponents([.day], from: Date(), to: nextWeekStart).day ?? 0
        return max(1, days)
    }
}
