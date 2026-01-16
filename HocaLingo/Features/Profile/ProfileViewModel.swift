//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Better direction change handling with user feedback
//  Location: HocaLingo/Features/Profile/ProfileViewModel.swift
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
        
        print("✅ ProfileViewModel initialized")
        print("   - Direction: \(studyDirection.displayName)")
        print("   - Theme: \(themeMode.displayName)")
        print("   - Daily Goal: \(dailyGoal)")
    }
    
    // MARK: - Settings Actions
    
    /// ✅ UPDATED: Change study direction with logging
    func changeStudyDirection(to direction: StudyDirection) {
        let oldDirection = studyDirection
        
        // Update local state
        studyDirection = direction
        
        // Save to UserDefaults
        UserDefaultsManager.shared.saveStudyDirection(direction)
        
        // Log the change
        print("🔄 Direction changed:")
        print("   - From: \(oldDirection.displayName)")
        print("   - To: \(direction.displayName)")
        print("   - Saved to UserDefaults")
        print("   ℹ️ Next study session will use new direction")
    }
    
    /// Change theme mode
    func changeThemeMode(to mode: ThemeMode) {
        themeMode = mode
        UserDefaultsManager.shared.saveThemeMode(mode)
        print("🎨 Theme changed to: \(mode.displayName)")
    }
    
    /// Change daily goal
    func changeDailyGoal(to goal: Int) {
        dailyGoal = goal
        UserDefaultsManager.shared.saveDailyGoal(goal)
        print("🎯 Daily goal changed to: \(goal)")
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()
        UserDefaultsManager.shared.saveNotificationsEnabled(notificationsEnabled)
        
        print("🔔 Notifications \(notificationsEnabled ? "enabled" : "disabled")")
        
        if notificationsEnabled {
            requestNotificationPermission()
        }
    }
    
    /// Change notification time
    func changeNotificationTime(to hour: Int) {
        notificationTime = hour
        UserDefaultsManager.shared.saveNotificationTime(hour)
        print("⏰ Notification time changed to: \(hour):00")
    }
    
    /// Refresh stats from storage
    func refreshStats() {
        userStats = UserDefaultsManager.shared.loadUserStats()
        print("🔄 Stats refreshed")
    }
    
    // MARK: - Notification Permission
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                } else {
                    print("⚠️ Notification permission denied")
                    self.notificationsEnabled = false
                    UserDefaultsManager.shared.saveNotificationsEnabled(false)
                }
            }
        }
    }
}
