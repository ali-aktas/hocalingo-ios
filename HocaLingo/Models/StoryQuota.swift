//
//  StoryQuota.swift
//  HocaLingo
//
//  AI Story Generation - Monthly Quota System
//  Free: 3 stories/month, Premium: 30 stories/month
//

import Foundation

/// Monthly story generation quota
/// Tracks usage and resets automatically at start of each month
struct StoryQuota: Codable, Equatable {
    let month: String        // "YYYY-MM" format (e.g., "2025-11")
    var usedCount: Int       // Number of stories generated this month
    let resetDate: Date      // First day of month at 00:00
    let isPremium: Bool      // Premium status at quota creation
    
    /// Monthly limit based on premium status
    /// Free: 3 stories/month
    /// Premium: 30 stories/month
    var limit: Int {
        return isPremium ? 30 : 3
    }
    
    /// Remaining stories for this month
    var remaining: Int {
        return max(0, limit - usedCount)
    }
    
    /// Check if user has quota remaining
    var hasQuota: Bool {
        return remaining > 0
    }
    
    /// Formatted quota text for UI
    /// Example: "2/3 kalan" or "25/30 kalan"
    var displayText: String {
        return "\(remaining)/\(limit)"
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard limit > 0 else { return 0 }
        return Double(usedCount) / Double(limit)
    }
    
    /// Initialize with current month
    init(month: String, usedCount: Int, resetDate: Date, isPremium: Bool) {
        self.month = month
        self.usedCount = usedCount
        self.resetDate = resetDate
        self.isPremium = isPremium
    }
    
    /// Create quota for current month
    static func current(isPremium: Bool) -> StoryQuota {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        
        // Month string: "2025-11"
        let monthString = String(format: "%04d-%02d", components.year!, components.month!)
        
        // First day of month at 00:00
        let firstOfMonth = calendar.date(from: components)!
        
        return StoryQuota(
            month: monthString,
            usedCount: 0,
            resetDate: firstOfMonth,
            isPremium: isPremium
        )
    }
    
    /// Check if quota needs reset (new month started)
    func needsReset() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        let currentMonth = String(format: "%04d-%02d", currentComponents.year!, currentComponents.month!)
        
        return month != currentMonth
    }
    
    /// Increment usage count
    mutating func increment() {
        usedCount += 1
    }
}

// MARK: - Quota Errors

extension StoryQuota {
    /// Error when trying to use quota without remaining stories
    var quotaExceededError: String {
        if isPremium {
            return "Aylık 30 hikaye limitine ulaştınız. Yeni ay başında devam edebilirsiniz."
        } else {
            return "Aylık 3 hikaye limitine ulaştınız. Premium ile 30 hikaye yazın!"
        }
    }
}
