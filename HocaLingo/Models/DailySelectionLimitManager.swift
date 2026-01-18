//
//  DailySelectionLimitManager.swift
//  HocaLingo
//
//  ✅ Manages daily selection limits (15/day for free users)
//  Location: HocaLingo/Core/Utils/DailySelectionLimitManager.swift
//

import Foundation

class DailySelectionLimitManager {
    static let shared = DailySelectionLimitManager()
    
    private let userDefaults = UserDefaults.standard
    private let dailyLimit = 15
    
    private let selectionsCountKey = "daily_selections_count"
    private let lastResetDateKey = "daily_selections_last_reset"
    
    private init() {
        checkAndResetIfNeeded()
    }
    
    var isPremium: Bool {
        // TODO: Connect to actual premium manager
        return false
    }
    
    private func checkAndResetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        
        if let lastReset = userDefaults.object(forKey: lastResetDateKey) as? Date {
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                resetCounter()
            }
        } else {
            userDefaults.set(now, forKey: lastResetDateKey)
        }
    }
    
    private func resetCounter() {
        userDefaults.set(0, forKey: selectionsCountKey)
        userDefaults.set(Date(), forKey: lastResetDateKey)
        print("🔄 Daily selection counter reset")
    }
    
    func canSelect() -> Bool {
        checkAndResetIfNeeded()
        
        if isPremium {
            return true
        }
        
        let currentCount = userDefaults.integer(forKey: selectionsCountKey)
        return currentCount < dailyLimit
    }
    
    func recordSelection() -> Int? {
        checkAndResetIfNeeded()
        
        if isPremium {
            return nil
        }
        
        var currentCount = userDefaults.integer(forKey: selectionsCountKey)
        currentCount += 1
        userDefaults.set(currentCount, forKey: selectionsCountKey)
        
        let remaining = dailyLimit - currentCount
        print("✅ Selection recorded: \(currentCount)/\(dailyLimit)")
        return max(0, remaining)
    }
    
    func undoSelection() {
        checkAndResetIfNeeded()
        
        if isPremium {
            return
        }
        
        var currentCount = userDefaults.integer(forKey: selectionsCountKey)
        currentCount = max(0, currentCount - 1)
        userDefaults.set(currentCount, forKey: selectionsCountKey)
        
        print("↩️ Selection undone: \(currentCount)/\(dailyLimit)")
    }
    
    func getRemainingSelections() -> Int {
        checkAndResetIfNeeded()
        
        if isPremium {
            return Int.max
        }
        
        let currentCount = userDefaults.integer(forKey: selectionsCountKey)
        return max(0, dailyLimit - currentCount)
    }
    
    func getCurrentCount() -> Int {
        checkAndResetIfNeeded()
        return userDefaults.integer(forKey: selectionsCountKey)
    }
    
    func shouldShowWarning() -> Bool {
        if isPremium {
            return false
        }
        
        let remaining = getRemainingSelections()
        return remaining <= 5 && remaining > 0
    }
}
