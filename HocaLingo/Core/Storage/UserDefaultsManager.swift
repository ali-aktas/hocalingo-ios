//
//  UserDefaultsManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Direction-aware progress storage (wordId + direction composite key)
//  Location: HocaLingo/Core/Storage/UserDefaultsManager.swift
//

import Foundation
import Combine

// MARK: - User Defaults Manager
/// Singleton manager for data persistence using UserDefaults
/// ✅ Supports dual progress tracking (EN→TR and TR→EN) per word
class UserDefaultsManager {
    
    // MARK: - Singleton
    static let shared = UserDefaultsManager()
    private init() {}
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let selectedWordIds = "selected_word_ids"
        static let selectedPackageId = "selected_package_id"
        static let studyDirection = "study_direction"
        static let themeMode = "theme_mode"
        static let dailyGoal = "daily_goal"
        static let notificationsEnabled = "notifications_enabled"
        static let notificationTime = "notification_time"
        static let progressData = "progress_data_"  // prefix for word progress
        static let userStats = "user_stats"
    }
    
    // MARK: - Selected Words Management
    
    /// Save selected word IDs to UserDefaults
    func saveSelectedWords(_ wordIds: [Int]) {
        UserDefaults.standard.set(wordIds, forKey: Keys.selectedWordIds)
    }
    
    /// Load selected word IDs from UserDefaults
    func loadSelectedWords() -> [Int] {
        return UserDefaults.standard.array(forKey: Keys.selectedWordIds) as? [Int] ?? []
    }
    
    /// Clear all selected words
    func clearSelectedWords() {
        UserDefaults.standard.removeObject(forKey: Keys.selectedWordIds)
    }
    
    // MARK: - Word Selections (Selected + Hidden)
        
    /// Get word selections for a package (selected and hidden)
    func getWordSelections(packageId: String) -> (selected: [Int], hidden: [Int]) {
        let selectedKey = "package_\(packageId)_selected"
        let hiddenKey = "package_\(packageId)_hidden"
            
        let selected = UserDefaults.standard.array(forKey: selectedKey) as? [Int] ?? []
        let hidden = UserDefaults.standard.array(forKey: hiddenKey) as? [Int] ?? []
            
        return (selected, hidden)
    }
        
    /// Save word selections for a package (selected and hidden)
    func saveWordSelections(packageId: String, selected: [Int], hidden: [Int]) {
        let selectedKey = "package_\(packageId)_selected"
        let hiddenKey = "package_\(packageId)_hidden"
        
        UserDefaults.standard.set(selected, forKey: selectedKey)
        UserDefaults.standard.set(hidden, forKey: hiddenKey)
    }
    
    /// Save selected package ID
    func saveSelectedPackage(_ packageId: String) {
        UserDefaults.standard.set(packageId, forKey: Keys.selectedPackageId)
    }
    
    /// Load selected package ID
    func loadSelectedPackage() -> String? {
        return UserDefaults.standard.string(forKey: Keys.selectedPackageId)
    }
    
    // MARK: - User Settings Management
    
    /// Save study direction
    func saveStudyDirection(_ direction: StudyDirection) {
        UserDefaults.standard.set(direction.rawValue, forKey: Keys.studyDirection)
    }
    
    /// Load study direction
    func loadStudyDirection() -> StudyDirection {
        if let rawValue = UserDefaults.standard.string(forKey: Keys.studyDirection),
           let direction = StudyDirection(rawValue: rawValue) {
            return direction
        }
        return .enToTr  // Default
    }
    
    /// Save theme mode
    func saveThemeMode(_ mode: ThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: Keys.themeMode)
    }
    
    /// Load theme mode
    func loadThemeMode() -> ThemeMode {
        if let rawValue = UserDefaults.standard.string(forKey: Keys.themeMode),
           let mode = ThemeMode(rawValue: rawValue) {
            return mode
        }
        return .system  // Default
    }
    
    /// Save daily goal
    func saveDailyGoal(_ goal: Int) {
        UserDefaults.standard.set(goal, forKey: Keys.dailyGoal)
    }
    
    /// Load daily goal
    func loadDailyGoal() -> Int {
        let goal = UserDefaults.standard.integer(forKey: Keys.dailyGoal)
        return goal > 0 ? goal : 20  // Default: 20 words/day
    }
    
    /// Save notifications enabled status
    func saveNotificationsEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.notificationsEnabled)
    }
    
    /// Load notifications enabled status
    func loadNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
    }
    
    /// Save notification time (hour of day: 0-23)
    func saveNotificationTime(_ hour: Int) {
        UserDefaults.standard.set(hour, forKey: Keys.notificationTime)
    }

    /// Load notification time
    /// ✅ FIXED: Default changed from 9 AM to 1 PM (13:00)
    func loadNotificationTime() -> Int {
        let hour = UserDefaults.standard.integer(forKey: Keys.notificationTime)
        return hour >= 0 && hour < 24 ? hour : 13  // ✅ Default: 1 PM (13:00) - was 9 AM
    }
    
    // MARK: - Progress Management (Direction-Aware)
    
    /// ✅ UPDATED: Save progress for a specific word with direction
    func saveProgress(_ progress: Progress, for wordId: Int, direction: StudyDirection) {
        let key = Keys.progressData + "\(wordId)_\(direction.rawValue)"
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    /// ✅ NEW: Load progress for specific word and direction
    func loadProgress(for wordId: Int, direction: StudyDirection) -> Progress? {
        // ✅ CRITICAL: Use composite key (wordId + direction)
        let key = Keys.progressData + "\(wordId)_\(direction.rawValue)"
        
        guard let data = UserDefaults.standard.data(forKey: key),
              let progress = try? JSONDecoder().decode(Progress.self, from: data) else {
            return nil
        }
        return progress
    }
    
    /// ✅ DEPRECATED: Old function (kept for backward compatibility)
    /// Use loadProgress(for:direction:) instead
    @available(*, deprecated, message: "Use loadProgress(for:direction:) instead")
    func loadProgress(for wordId: Int) -> Progress? {
        // Try to load EN→TR by default for backward compatibility
        return loadProgress(for: wordId, direction: .enToTr)
    }
    
    /// ✅ UPDATED: Load all progress (filtered by direction)
    /// Returns [wordId: Progress] dictionary for specific direction
    func loadAllProgress(for direction: StudyDirection) -> [Int: Progress] {
        var allProgress: [Int: Progress] = [:]
        let selectedWords = loadSelectedWords()
        
        for wordId in selectedWords {
            if let progress = loadProgress(for: wordId, direction: direction) {
                allProgress[wordId] = progress
            }
        }
        
        return allProgress
    }
    
    /// ✅ NEW: Delete progress for specific word and direction
    func deleteProgress(for wordId: Int, direction: StudyDirection) {
        let key = Keys.progressData + "\(wordId)_\(direction.rawValue)"
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    /// ✅ UPDATED: Delete progress for a specific word (both directions)
    func deleteProgress(for wordId: Int) {
        // Delete both directions
        deleteProgress(for: wordId, direction: .enToTr)
        deleteProgress(for: wordId, direction: .trToEn)
    }
    
    /// ✅ UPDATED: Clear all progress data (both directions)
    func clearAllProgress() {
        let selectedWords = loadSelectedWords()
        for wordId in selectedWords {
            deleteProgress(for: wordId) // Deletes both directions
        }
    }
    
    // MARK: - User Stats Management
    
    /// Save user stats
    func saveUserStats(_ stats: UserStats) {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: Keys.userStats)
        }
    }
    
    /// Load user stats
    func loadUserStats() -> UserStats {
        guard let data = UserDefaults.standard.data(forKey: Keys.userStats),
              let stats = try? JSONDecoder().decode(UserStats.self, from: data) else {
            // Return default stats if none exist
            return UserStats.empty
        }
        return stats
    }
    
    /// Update user stats (increment counters)
    func updateStats(wordsStudiedToday: Int = 0, studyTimeMinutes: Int = 0) {
        var stats = loadUserStats()
        
        if wordsStudiedToday > 0 {
            stats.totalWordsStudied += wordsStudiedToday
            stats.wordsStudiedToday += wordsStudiedToday
        }
        
        if studyTimeMinutes > 0 {
            stats.totalStudyTime += studyTimeMinutes
            stats.studyTimeThisWeek += studyTimeMinutes
        }
        
        saveUserStats(stats)
    }
    
    // MARK: - Utility Methods
    
    /// Reset all user data (for testing or logout)
    func resetAllData() {
        clearSelectedWords()
        clearAllProgress()
        UserDefaults.standard.removeObject(forKey: Keys.selectedPackageId)
        UserDefaults.standard.removeObject(forKey: Keys.userStats)
        // Keep settings (theme, direction, etc.)
    }
    
    /// Check if user has selected words
    func hasSelectedWords() -> Bool {
        return !loadSelectedWords().isEmpty
    }
}
