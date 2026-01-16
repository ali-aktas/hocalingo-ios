//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ MEGA UPDATE: NotificationCenter post on direction change (real-time update)
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
    
    /// ✅ MEGA FIX 3: Change study direction with NotificationCenter
    func changeStudyDirection(to direction: StudyDirection) {
        let oldDirection = studyDirection
        
        // Update local state
        studyDirection = direction
        
        // Save to UserDefaults
        UserDefaultsManager.shared.saveStudyDirection(direction)
        
        // ✅ NEW: Post notification to StudyViewModel
        NotificationCenter.default.post(
            name: NSNotification.Name("StudyDirectionChanged"),
            object: nil
        )
        
        // Log the change
        print("🔄 Direction changed:")
        print("   - From: \(oldDirection.displayName)")
        print("   - To: \(direction.displayName)")
        print("   - Saved to UserDefaults")
        print("   📡 Notification posted to StudyViewModel")
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
        
        if notificationsEnabled {
            scheduleNotifications()
        }
        
        print("⏰ Notification time changed to: \(hour):00")
    }
    
    // MARK: - Notification Management
    
    /// Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleNotifications()
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Schedule daily notifications
    private func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "HocaLingo"
        content.body = "Bugünkü kelimelerini çalışma zamanı! 📚"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = notificationTime
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_study_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily notification scheduled for \(self.notificationTime):00")
            }
        }
    }
    
    /// Remove all scheduled notifications
    private func removeNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ All notifications removed")
    }
    
    // MARK: - Premium Actions
    
    func upgradeToPremium() {
        // TODO: Connect to RevenueCat
        print("💎 Premium upgrade requested")
    }
}
