//
//  ProfileViewModel.swift
//  HocaLingo
//
//  Updated on 15.01.2026.
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Profile View Model
/// Business logic for profile screen with real data persistence
/// Location: HocaLingo/Features/Profile/ProfileViewModel.swift
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userStats: UserStats
    @Published var studyDirection: StudyDirection
    @Published var themeMode: ThemeMode
    @Published var dailyGoal: Int
    @Published var notificationsEnabled: Bool
    @Published var notificationTime: Int
    @Published var isPremium: Bool = false // TODO: Connect to RevenueCat
    
    // MARK: - Initialization
    init() {
        // Load all settings from UserDefaults
        self.userStats = UserDefaultsManager.shared.loadUserStats()
        self.studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        self.themeMode = UserDefaultsManager.shared.loadThemeMode()
        self.dailyGoal = UserDefaultsManager.shared.loadDailyGoal()
        self.notificationsEnabled = UserDefaultsManager.shared.loadNotificationsEnabled()
        self.notificationTime = UserDefaultsManager.shared.loadNotificationTime()
    }
    
    // MARK: - Settings Actions
    
    /// Change study direction
    func changeStudyDirection(to direction: StudyDirection) {
        studyDirection = direction
        UserDefaultsManager.shared.saveStudyDirection(direction)
    }
    
    /// Change theme mode
    func changeThemeMode(to mode: ThemeMode) {
        themeMode = mode
        UserDefaultsManager.shared.saveThemeMode(mode)
    }
    
    /// Change daily goal
    func changeDailyGoal(to goal: Int) {
        dailyGoal = goal
        UserDefaultsManager.shared.saveDailyGoal(goal)
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()
        UserDefaultsManager.shared.saveNotificationsEnabled(notificationsEnabled)
        
        if notificationsEnabled {
            requestNotificationPermission()
        }
    }
    
    /// Change notification time
    func changeNotificationTime(to hour: Int) {
        notificationTime = hour
        UserDefaultsManager.shared.saveNotificationTime(hour)
    }
    
    /// Refresh stats from storage
    func refreshStats() {
        userStats = UserDefaultsManager.shared.loadUserStats()
    }
    
    /// Reset all user data (for testing)
    func resetAllData() {
        UserDefaultsManager.shared.resetAllData()
        refreshStats()
    }
    
    // MARK: - Helper Methods
    
    /// Request notification permission (iOS)
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    self.notificationsEnabled = false
                    UserDefaultsManager.shared.saveNotificationsEnabled(false)
                }
            }
        }
    }
    
    /// Get formatted study time
    var formattedStudyTime: String {
        let hours = userStats.totalStudyTime / 60
        let minutes = userStats.totalStudyTime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Get selected words count
    var selectedWordsCount: Int {
        return UserDefaultsManager.shared.loadSelectedWords().count
    }
}
