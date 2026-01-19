//
//  UserDefaultsManager+AnnualStats.swift
//  HocaLingo
//
//  Annual statistics tracking extension - calculates yearly stats from daily data
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+AnnualStats.swift
//

import Foundation

// MARK: - Annual Stats Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum AnnualKeys {
        static let annualStats = "annual_stats"
        static let wordsSkippedThisYear = "words_skipped_this_year"
        static let lastYearReset = "last_year_reset"
    }
    
    // MARK: - Annual Stats Calculation
    
    /// Calculate and return annual statistics for current year
    /// Reads all daily stats from UserDefaults and aggregates them
    func calculateAnnualStats() -> AnnualStats {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of current year (January 1st)
        guard let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now)) else {
            return AnnualStats.empty
        }
        
        // Date formatter for daily stats keys
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        var activeDays = 0
        var totalMinutes = 0
        
        // Iterate through each day from year start to today
        var currentDate = yearStart
        while currentDate <= now {
            let dateString = dateFormatter.string(from: currentDate)
            
            // Load stats for this date
            if let dayStats = loadDailyStats(for: dateString) {
                // Count as active day if any words were studied
                if dayStats.wordsStudied > 0 {
                    activeDays += 1
                }
                
                // Add study time
                totalMinutes += dayStats.studyTimeMinutes
            }
            
            // Move to next day
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        // Convert minutes to hours (rounded)
        let studyHours = totalMinutes / 60
        
        // Load skipped words count
        let wordsSkipped = loadWordsSkippedThisYear()
        
        let annualStats = AnnualStats(
            activeDaysThisYear: activeDays,
            studyHoursThisYear: studyHours,
            wordsSkippedThisYear: wordsSkipped
        )
        
        // Cache the calculated stats
        saveAnnualStats(annualStats)
        
        print("📊 Annual stats calculated:")
        print("   - Active days: \(activeDays)")
        print("   - Study hours: \(studyHours)")
        print("   - Words skipped: \(wordsSkipped)")
        
        return annualStats
    }
    
    // MARK: - Annual Stats Storage
    
    /// Save calculated annual stats to cache
    private func saveAnnualStats(_ stats: AnnualStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: AnnualKeys.annualStats)
        }
    }
    
    /// Load cached annual stats (returns nil if not cached)
    func loadCachedAnnualStats() -> AnnualStats? {
        guard let data = UserDefaults.standard.data(forKey: AnnualKeys.annualStats),
              let stats = try? JSONDecoder().decode(AnnualStats.self, from: data) else {
            return nil
        }
        return stats
    }
    
    /// Load annual stats (calculates if not cached)
    func loadAnnualStats() -> AnnualStats {
        // Try to load cached stats
        if let cached = loadCachedAnnualStats() {
            return cached
        }
        
        // Calculate if not cached
        return calculateAnnualStats()
    }
    
    // MARK: - Words Skipped Tracking
    
    /// Increment words skipped counter
    /// Called when user swipes left on a word in word selection
    func incrementWordsSkipped() {
        let current = loadWordsSkippedThisYear()
        UserDefaults.standard.set(current + 1, forKey: AnnualKeys.wordsSkippedThisYear)
        
        print("📈 Words skipped incremented: \(current + 1)")
    }
    
    /// Load words skipped this year
    func loadWordsSkippedThisYear() -> Int {
        return UserDefaults.standard.integer(forKey: AnnualKeys.wordsSkippedThisYear)
    }
    
    // MARK: - Year Reset
    
    /// Check if we need to reset annual stats for new year
    /// Call this on app launch
    func checkAndResetAnnualStatsIfNeeded() {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        
        // Get last reset year
        let lastResetYear = UserDefaults.standard.integer(forKey: AnnualKeys.lastYearReset)
        
        // Reset if new year
        if lastResetYear != currentYear {
            print("🎉 New year detected! Resetting annual stats...")
            resetAnnualStats()
            UserDefaults.standard.set(currentYear, forKey: AnnualKeys.lastYearReset)
        }
    }
    
    /// Reset annual stats (called at start of new year)
    private func resetAnnualStats() {
        UserDefaults.standard.removeObject(forKey: AnnualKeys.annualStats)
        UserDefaults.standard.set(0, forKey: AnnualKeys.wordsSkippedThisYear)
        
        print("🔄 Annual stats reset for new year")
    }
}
