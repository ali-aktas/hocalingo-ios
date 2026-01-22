//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ MAJOR UPDATE: Instant language change, proper theme handling, annual stats
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
    @Published var annualStats: AnnualStats
    
    // Settings
    @Published var studyDirection: StudyDirection
    @Published var themeMode: ThemeMode
    @Published var appLanguage: AppLanguage
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
        self.annualStats = UserDefaultsManager.shared.loadAnnualStats()
        self.studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        self.themeMode = UserDefaultsManager.shared.loadThemeMode()
        self.appLanguage = UserDefaultsManager.shared.loadAppLanguage()
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
    
    /// ✅ INSTANT language change - @AppStorage handles everything automatically
    /// When we update UserDefaults, @AppStorage in HocaLingoApp detects it and rebuilds UI
    func changeLanguage(to language: AppLanguage) {
        let oldLanguage = appLanguage
        
        // Update local state FIRST (for immediate UI feedback in ProfileView)
        appLanguage = language
        
        // Save to UserDefaults
        UserDefaultsManager.shared.saveAppLanguage(language)
        
        // ✅ CRITICAL: Post notification for all views to refresh
        NotificationCenter.default.post(
            name: NSNotification.Name("AppLanguageChanged"),
            object: nil
        )
        
        print("🌍 Language changed:")
        print("   - From: \(oldLanguage.displayName)")
        print("   - To: \(language.displayName)")
        print("   - Notification posted to all views")
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
        
        print("⏰ Notification time changed to: \(String(format: "%02d:00", hour))")
        
        if notificationsEnabled {
            // TODO: Reschedule notification with new time
        }
    }
    
    /// Refresh annual statistics
    func refreshAnnualStats() {
        annualStats = UserDefaultsManager.shared.loadAnnualStats()
        print("📊 Annual stats refreshed: \(annualStats.activeDaysThisYear) days")
    }
    
    // MARK: - Notification Permission
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print("⚠️ Notification permission denied")
            }
        }
    }
}
