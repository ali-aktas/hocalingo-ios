//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ MAJOR UPDATE: Language selection, Annual stats, Improved notification UI
//  Location: HocaLingo/Features/Profile/ProfileViewModel.swift
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Profile View Model
/// Business logic for profile screen with comprehensive settings management
/// Location: HocaLingo/Features/Profile/ProfileViewModel.swift
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    // User Statistics
    @Published var userStats: UserStats
    @Published var annualStats: AnnualStats  // ✅ NEW: Yearly statistics
    
    // Settings
    @Published var studyDirection: StudyDirection
    @Published var themeMode: ThemeMode
    @Published var appLanguage: AppLanguage  // ✅ NEW: App language selection
    @Published var notificationsEnabled: Bool
    @Published var notificationTime: Int  // Hour: 0-23
    
    // Premium status
    @Published var isPremium: Bool = false // TODO: Connect to RevenueCat
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Load all settings from UserDefaults
        self.userStats = UserDefaultsManager.shared.loadUserStats()
        self.annualStats = UserDefaultsManager.shared.loadAnnualStats()  // ✅ NEW
        self.studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        self.themeMode = UserDefaultsManager.shared.loadThemeMode()
        self.appLanguage = UserDefaultsManager.shared.loadAppLanguage()  // ✅ NEW
        self.notificationsEnabled = UserDefaultsManager.shared.loadNotificationsEnabled()
        self.notificationTime = UserDefaultsManager.shared.loadNotificationTime()
        
        // Check and reset annual stats if new year
        UserDefaultsManager.shared.checkAndResetAnnualStatsIfNeeded()
        
        print("✅ ProfileViewModel initialized")
        print("   - Direction: \(studyDirection.displayName)")
        print("   - Theme: \(themeMode.displayName)")
        print("   - Language: \(appLanguage.displayName)")
        print("   - Notification time: \(notificationTime):00")
        print("   - Annual stats: \(annualStats.activeDaysThisYear) days, \(annualStats.studyHoursThisYear) hours")
    }
    
    // MARK: - Computed Properties
    
    /// Formatted notification time for display (HH:MM format)
    var notificationTimeFormatted: String {
        return String(format: "%02d:00", notificationTime)
    }
    
    /// Total hidden words count (words skipped = words swiped left)
    var totalHiddenWordsCount: Int {
        return UserDefaultsManager.shared.getTotalHiddenWordsCount()
    }
    
    // MARK: - Settings Actions
    
    /// ✅ UPDATED: Change study direction with NotificationCenter
    func changeStudyDirection(to direction: StudyDirection) {
        let oldDirection = studyDirection
        
        // Update local state
        studyDirection = direction
        
        // Save to UserDefaults
        UserDefaultsManager.shared.saveStudyDirection(direction)
        
        // Post notification to StudyViewModel for real-time update
        NotificationCenter.default.post(
            name: NSNotification.Name("StudyDirectionChanged"),
            object: nil
        )
        
        print("🔄 Direction changed:")
        print("   - From: \(oldDirection.displayName)")
        print("   - To: \(direction.displayName)")
        print("   - Notification posted to StudyViewModel")
    }
    
    /// ✅ UPDATED: Change theme mode with proper system-wide update
    func changeThemeMode(to mode: ThemeMode) {
        themeMode = mode
        UserDefaultsManager.shared.saveThemeMode(mode)
        
        // Post notification for app-wide theme change
        NotificationCenter.default.post(
            name: NSNotification.Name("ThemeModeChanged"),
            object: nil,
            userInfo: ["themeMode": mode]
        )
        
        print("🎨 Theme changed to: \(mode.displayName)")
    }
    
    /// ✅ NEW: Change app language
    func changeLanguage(to language: AppLanguage) {
        let oldLanguage = appLanguage
        
        // Update local state
        appLanguage = language
        
        // Save to UserDefaults (this also applies the change)
        UserDefaultsManager.shared.saveAppLanguage(language)
        
        print("🌍 Language changed:")
        print("   - From: \(oldLanguage.displayName)")
        print("   - To: \(language.displayName)")
        print("   ⚠️ App restart required for full language change")
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        notificationsEnabled.toggle()
        UserDefaultsManager.shared.saveNotificationsEnabled(notificationsEnabled)
        
        print("🔔 Notifications \(notificationsEnabled ? "enabled" : "disabled")")
        
        if notificationsEnabled {
            requestNotificationPermission()
        } else {
            cancelScheduledNotifications()
        }
    }
    
    /// ✅ UPDATED: Change notification time with better formatting
    func changeNotificationTime(to hour: Int) {
        guard hour >= 0 && hour < 24 else {
            print("⚠️ Invalid notification hour: \(hour)")
            return
        }
        
        notificationTime = hour
        UserDefaultsManager.shared.saveNotificationTime(hour)
        
        // Reschedule if notifications are enabled
        if notificationsEnabled {
            scheduleNotifications()
        }
        
        print("⏰ Notification time changed to: \(notificationTimeFormatted)")
    }
    
    /// ✅ NEW: Refresh annual statistics
    func refreshAnnualStats() {
        annualStats = UserDefaultsManager.shared.calculateAnnualStats()
        print("📊 Annual stats refreshed:")
        print("   - Active days: \(annualStats.activeDaysThisYear)")
        print("   - Study hours: \(annualStats.studyHoursThisYear)")
        print("   - Words skipped: \(annualStats.wordsSkippedThisYear)")
    }
    
    /// Refresh all profile data
    func refreshProfile() {
        userStats = UserDefaultsManager.shared.loadUserStats()
        annualStats = UserDefaultsManager.shared.calculateAnnualStats()
        print("🔄 Profile data refreshed")
    }
    
    // MARK: - Notification Management
    
    /// Request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleNotifications()
                    print("✅ Notification permission granted")
                } else {
                    // Permission denied, revert toggle
                    self.notificationsEnabled = false
                    UserDefaultsManager.shared.saveNotificationsEnabled(false)
                    print("❌ Notification permission denied")
                    
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    /// Schedule daily notifications
    private func scheduleNotifications() {
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "HocaLingo"
        content.body = "Bugünkü kelimelerini çalışma zamanı! 📚"
        content.sound = .default
        content.badge = 1
        
        // Create trigger for daily notification at specified hour
        var dateComponents = DateComponents()
        dateComponents.hour = notificationTime
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("✅ Daily notification scheduled for \(self.notificationTimeFormatted)")
            }
        }
    }
    
    /// Cancel all scheduled notifications
    private func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🔕 All notifications cancelled")
    }
}
