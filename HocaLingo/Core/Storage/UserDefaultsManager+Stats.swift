//
//  UserDefaultsManager+Stats.swift
//  HocaLingo
//
//  Stats tracking extension - Daily/Monthly graduation tracking (Android parity)
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+Stats.swift
//

import Foundation

// MARK: - Daily Stats Model
/// Daily study statistics - matches Android DailyStatsEntity
struct DailyStats: Codable {
    let date: String // ISO date: "2025-01-17"
    var wordsGraduated: Int // Words that graduated today (learning → review)
    var wordsStudied: Int // Total cards studied today
    var studyTimeMinutes: Int // Study time in minutes
    var goalAchieved: Bool // Whether daily goal was reached
    
    init(date: String, wordsGraduated: Int = 0, wordsStudied: Int = 0, studyTimeMinutes: Int = 0, goalAchieved: Bool = false) {
        self.date = date
        self.wordsGraduated = wordsGraduated
        self.wordsStudied = wordsStudied
        self.studyTimeMinutes = studyTimeMinutes
        self.goalAchieved = goalAchieved
    }
}

// MARK: - Stats Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum StatsKeys {
        static let dailyStatsPrefix = "daily_stats_" // daily_stats_2025-01-17
        static let monthlyStudiedDays = "monthly_studied_days"
        static let lastStudyDate = "last_study_date"
    }
    
    // MARK: - Daily Stats
    
    /// Load daily stats for a specific date
    func loadDailyStats(for date: String) -> DailyStats? {
        let key = StatsKeys.dailyStatsPrefix + date
        guard let data = UserDefaults.standard.data(forKey: key),
              let stats = try? JSONDecoder().decode(DailyStats.self, from: data) else {
            return nil
        }
        return stats
    }
    
    // MARK: - Tarih Yardımcısı (Hata payını sıfırlar)
    private func getLocalDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current // Kullanıcının yerel saatini baz al
        return formatter.string(from: date)
    }

    // getTodayDateString metodunu bununla değiştir:
    private func getTodayDateString() -> String {
        return getLocalDateString(from: Date())
    }
    
    /// Save daily stats for a specific date
    func saveDailyStats(_ stats: DailyStats) {
        let key = StatsKeys.dailyStatsPrefix + stats.date
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    /// Get or create today's daily stats
    func getTodayDailyStats() -> DailyStats {
        let today = getTodayDateString()
        return loadDailyStats(for: today) ?? DailyStats(date: today)
    }
    
    /// ✅ CRITICAL: Increment words graduated (Android parity)
    /// Called when a word graduates from learning to review phase
    func incrementDailyGraduations() {
        var todayStats = getTodayDailyStats()
        todayStats.wordsGraduated += 1
        
        // Check if goal is achieved
        let dailyGoal = loadDailyGoal()
        todayStats.goalAchieved = todayStats.wordsGraduated >= dailyGoal
        
        saveDailyStats(todayStats)
        
        // Update UserStats
        var userStats = loadUserStats()
        userStats.wordsStudiedToday = todayStats.wordsGraduated
        
        // ✅ NEW: Update streak
        updateStreak()
        
        saveUserStats(userStats)
        
        // Mark today as studied (for monthly active days)
        markTodayAsStudied()
        
        // Save last study date
        saveLastStudyDate(Date())
        
        print("📈 Daily graduation incremented:")
        print("   - Date: \(todayStats.date)")
        print("   - Graduations: \(todayStats.wordsGraduated)/\(dailyGoal)")
        print("   - Goal achieved: \(todayStats.goalAchieved)")
    }
    
    /// Increment total cards studied (not just graduations)
    func incrementCardsStudied() {
        var todayStats = getTodayDailyStats()
        todayStats.wordsStudied += 1
        saveDailyStats(todayStats)
    }
    
    /// Add study time to today's stats
    func addStudyTime(minutes: Int) {
        var todayStats = getTodayDailyStats()
        todayStats.studyTimeMinutes += minutes
        saveDailyStats(todayStats)
        
        // Update UserStats
        var userStats = loadUserStats()
        userStats.totalStudyTime += minutes
        userStats.studyTimeThisWeek += minutes
        saveUserStats(userStats)
    }
    
    // MARK: - Monthly Stats
    
    /// Save last study date
    func saveLastStudyDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: StatsKeys.lastStudyDate)
    }
    
    /// Load last study date
    func loadLastStudyDate() -> Date? {
        return UserDefaults.standard.object(forKey: StatsKeys.lastStudyDate) as? Date
    }
    
    /// Get studied days count for current month
    func getMonthlyStudiedDaysCount() -> Int {
        let days = loadMonthlyStudiedDays()
        return days.count
    }
    
    /// Clear monthly data (call at start of new month)
    func clearMonthlyStatsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastStudy = loadLastStudyDate() {
            let lastMonth = calendar.component(.month, from: lastStudy)
            let currentMonth = calendar.component(.month, from: today)
            
            if lastMonth != currentMonth {
                // New month, clear old data
                clearMonthlyData()
                print("🗓️ New month detected, monthly stats cleared")
            }
        }
    }
    
    // MARK: - Mastered Words Count
    
    /// Calculate mastered words count (words with 21+ day interval in review phase)
    func calculateMasteredWordsCount(direction: StudyDirection) -> Int {
        let allProgress = loadAllProgress(for: direction)
        
        let masteredCount = allProgress.values.filter { progress in
            !progress.learningPhase && progress.intervalDays >= 21.0
        }.count
        
        return masteredCount
    }
    
    /// Calculate total mastered words (both directions)
    func calculateTotalMasteredWords() -> Int {
        let enToTrCount = calculateMasteredWordsCount(direction: .enToTr)
        let trToEnCount = calculateMasteredWordsCount(direction: .trToEn)
        
        // Take max to avoid double counting
        // (a word is mastered if it's mastered in at least one direction)
        let selectedWords = Set(loadSelectedWords())
        var masteredWords = Set<Int>()
        
        for wordId in selectedWords {
            if let progressEnToTr = loadProgress(for: wordId, direction: .enToTr),
               !progressEnToTr.learningPhase && progressEnToTr.intervalDays >= 21.0 {
                masteredWords.insert(wordId)
            }
            
            if let progressTrToEn = loadProgress(for: wordId, direction: .trToEn),
               !progressTrToEn.learningPhase && progressTrToEn.intervalDays >= 21.0 {
                masteredWords.insert(wordId)
            }
        }
        
        return masteredWords.count
    }
    
    /// ✅ NEW: Calculate learned words count (30+ day interval in review phase)
    func calculateTotalLearnedWords() -> Int {
        let selectedWords = Set(loadSelectedWords())
        var learnedWords = Set<Int>()
        
        for wordId in selectedWords {
            // Check both directions
            if let progressEnToTr = loadProgress(for: wordId, direction: .enToTr),
               !progressEnToTr.learningPhase && progressEnToTr.intervalDays >= 21.0 {
                learnedWords.insert(wordId)
            }
            
            if let progressTrToEn = loadProgress(for: wordId, direction: .trToEn),
               !progressTrToEn.learningPhase && progressTrToEn.intervalDays >= 21.0 {
                learnedWords.insert(wordId)
            }
        }
        
        return learnedWords.count
    }
    
    /// Update mastered words count in UserStats
    func updateMasteredWordsCount() {
        var stats = loadUserStats()
        stats.masteredWordsCount = calculateTotalMasteredWords()
        saveUserStats(stats)
        
        print("⭐ Mastered words updated: \(stats.masteredWordsCount)")
    }
    
    // MARK: - Weekly Stats Reset
    
    /// Reset weekly stats (call on Monday)
    func resetWeeklyStatsIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // If it's Monday (weekday = 2 in Gregorian calendar)
        if weekday == 2 {
            if let lastStudy = loadLastStudyDate() {
                let lastWeekday = calendar.component(.weekday, from: lastStudy)
                
                // If last study was not Monday, reset weekly stats
                if lastWeekday != 2 {
                    var stats = loadUserStats()
                    stats.studyTimeThisWeek = 0
                    saveUserStats(stats)
                    
                    print("📅 Weekly stats reset (new week started)")
                }
            }
        }
    }
    
    // MARK: - Streak Calculation
    /// NEW: Update streak based on last study date
    private func updateStreak() {
        var stats = loadUserStats()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let lastStudy = loadLastStudyDate() else {
            // First time studying
            stats.currentStreak = 1
            stats.longestStreak = max(stats.longestStreak, 1)
            saveUserStats(stats)
            print("🔥 Streak started: 1 day")
            return
        }
        
        let lastStudyDay = calendar.startOfDay(for: lastStudy)
        let daysDiff = calendar.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
        
        switch daysDiff {
        case 0:
            // Already studied today, no change
            print("🔥 Streak maintained: \(stats.currentStreak) days (already studied today)")
            
        case 1:
            // Studied yesterday, increment streak
            stats.currentStreak += 1
            stats.longestStreak = max(stats.longestStreak, stats.currentStreak)
            saveUserStats(stats)
            print("🔥 Streak increased: \(stats.currentStreak) days")
            
        default:
            // Missed a day, reset streak
            stats.currentStreak = 1
            saveUserStats(stats)
            print("💔 Streak broken! Restarting: 1 day")
        }
    }
    
}
