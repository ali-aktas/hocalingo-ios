//
//  QuotaManager.swift
//  HocaLingo
//
//  Core/Storage/QuotaManager.swift
//  Monthly story generation quota management
//  Free: 3/month, Premium: 30/month
//

import Foundation

/// Monthly quota manager
/// Tracks story generation usage with automatic monthly reset
class QuotaManager {
    
    // MARK: - Storage Key
    
    private let storageKey = "ai_story_quota"
    
    // MARK: - UserDefaults
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Public Methods
    
    /// Get current month's quota
    /// Auto-resets if new month started
    /// - Parameter isPremium: Current premium status
    /// - Returns: Current quota state
    func getCurrentQuota(isPremium: Bool) -> StoryQuota {
        // Load existing quota
        if let data = defaults.data(forKey: storageKey),
           let quota = try? JSONDecoder().decode(StoryQuota.self, from: data) {
            
            // Check if month changed (needs reset)
            if quota.needsReset() {
                // New month started, create fresh quota
                let newQuota = StoryQuota.current(isPremium: isPremium)
                save(quota: newQuota)
                return newQuota
            }
            
            // Check if premium status changed
            if quota.isPremium != isPremium {
                // Premium status changed, update quota
                var updatedQuota = quota
                let newQuota = StoryQuota(
                    month: updatedQuota.month,
                    usedCount: updatedQuota.usedCount,
                    resetDate: updatedQuota.resetDate,
                    isPremium: isPremium
                )
                save(quota: newQuota)
                return newQuota
            }
            
            return quota
        }
        
        // No existing quota, create new
        let quota = StoryQuota.current(isPremium: isPremium)
        save(quota: quota)
        return quota
    }
    
    /// Increment quota usage
    /// - Parameter isPremium: Current premium status
    /// - Throws: AIStoryError.quotaExceeded if limit reached
    func incrementQuota(isPremium: Bool) throws {
        var quota = getCurrentQuota(isPremium: isPremium)
        
        // Check if quota available
        guard quota.hasQuota else {
            throw AIStoryError.quotaExceeded(
                remaining: quota.remaining,
                limit: quota.limit
            )
        }
        
        // Increment usage
        quota.increment()
        
        // Save updated quota
        save(quota: quota)
    }
    
    /// Reset quota (for testing or manual reset)
    /// - Parameter isPremium: Current premium status
    func resetQuota(isPremium: Bool) {
        let newQuota = StoryQuota.current(isPremium: isPremium)
        save(quota: newQuota)
    }
    
    /// Get quota info for UI display
    /// - Parameter isPremium: Current premium status
    /// - Returns: (used, total) tuple
    func getQuotaInfo(isPremium: Bool) -> (used: Int, total: Int) {
        let quota = getCurrentQuota(isPremium: isPremium)
        return (used: quota.usedCount, total: quota.limit)
    }
    
    // MARK: - Private Helpers
    
    /// Save quota to UserDefaults
    private func save(quota: StoryQuota) {
        if let data = try? JSONEncoder().encode(quota) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    /// Delete all quota data (for debugging)
    func clearAll() {
        defaults.removeObject(forKey: storageKey)
    }
}

// MARK: - Quota Extensions

extension QuotaManager {
    /// Check if user can generate story
    /// - Parameter isPremium: Current premium status
    /// - Returns: Boolean indicating availability
    func canGenerateStory(isPremium: Bool) -> Bool {
        let quota = getCurrentQuota(isPremium: isPremium)
        return quota.hasQuota
    }
    
    /// Get remaining stories count
    /// - Parameter isPremium: Current premium status
    /// - Returns: Number of remaining stories
    func remainingStories(isPremium: Bool) -> Int {
        let quota = getCurrentQuota(isPremium: isPremium)
        return quota.remaining
    }
    
    /// Get quota reset date
    /// - Parameter isPremium: Current premium status
    /// - Returns: Date when quota will reset
    func resetDate(isPremium: Bool) -> Date {
        let quota = getCurrentQuota(isPremium: isPremium)
        
        // Calculate next month's first day
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: quota.resetDate) {
            let components = calendar.dateComponents([.year, .month], from: nextMonth)
            return calendar.date(from: components)!
        }
        
        return quota.resetDate
    }
    
    /// Get days until reset
    /// - Parameter isPremium: Current premium status
    /// - Returns: Number of days until quota resets
    func daysUntilReset(isPremium: Bool) -> Int {
        let nextReset = resetDate(isPremium: isPremium)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextReset)
        return max(0, components.day ?? 0)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension QuotaManager {
    /// Set custom quota for testing
    func setTestQuota(usedCount: Int, isPremium: Bool) {
        var quota = getCurrentQuota(isPremium: isPremium)
        let testQuota = StoryQuota(
            month: quota.month,
            usedCount: usedCount,
            resetDate: quota.resetDate,
            isPremium: isPremium
        )
        save(quota: testQuota)
    }
    
    /// Get all quota data for debugging
    func debugInfo(isPremium: Bool) -> String {
        let quota = getCurrentQuota(isPremium: isPremium)
        return """
        Month: \(quota.month)
        Used: \(quota.usedCount)
        Limit: \(quota.limit)
        Remaining: \(quota.remaining)
        Premium: \(quota.isPremium)
        Reset Date: \(quota.resetDate)
        """
    }
}
#endif
