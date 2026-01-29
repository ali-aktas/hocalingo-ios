//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Premium status observation added (minimal change)
//  Location: Features/Profile/ProfileViewModel.swift
//

import SwiftUI
import Combine
import UserNotifications

// MARK: - Profile View Model
/// Business logic for profile screen with comprehensive settings management
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
    
    // ✅ UPDATED: Now synced with PremiumManager
    @Published var isPremium: Bool = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Load all settings from UserDefaults
        self.userStats = UserDefaultsManager.shared.loadUserStats()
        self.annualStats = UserDefaultsManager.shared.calculateAnnualStats()
        self.studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        self.themeMode = UserDefaultsManager.shared.loadThemeMode()
        self.appLanguage = UserDefaultsManager.shared.loadAppLanguage()
        self.notificationsEnabled = UserDefaultsManager.shared.loadNotificationsEnabled()
        self.notificationTime = UserDefaultsManager.shared.loadNotificationTime()
        
        // ✅ NEW: Load premium status
        self.isPremium = PremiumManager.shared.isPremium
        
        // Check and reset annual stats if new year
        UserDefaultsManager.shared.checkAndResetAnnualStatsIfNeeded()
        
        // ✅ NEW: Observe premium status changes
        observePremiumStatus()
        
        print("✅ ProfileViewModel initialized")
    }
    
    // MARK: - ✅ NEW: Premium Status Observer
    
    /// Observe premium status changes from PremiumManager
    private func observePremiumStatus() {
        PremiumManager.shared.$isPremium
            .sink { [weak self] newStatus in
                self?.isPremium = newStatus
            }
            .store(in: &cancellables)
    }

    /// Forces a recalculation of annual statistics
    func refreshAnnualStats() {
        annualStats = UserDefaultsManager.shared.calculateAnnualStats()
        print("📊 Annual stats refreshed: \(annualStats.activeDaysThisYear) days")
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
    
    /// Changes study direction and notifies other view models
    func changeStudyDirection(to direction: StudyDirection) {
        studyDirection = direction
        UserDefaultsManager.shared.saveStudyDirection(direction)
        
        // Notify StudyViewModel for real-time updates
        NotificationCenter.default.post(
            name: NSNotification.Name("StudyDirectionChanged"),
            object: nil
        )
    }
    
    /// Updates app theme mode system-wide
    func changeThemeMode(to mode: ThemeMode) {
        themeMode = mode
        UserDefaultsManager.shared.saveThemeMode(mode)
        
        NotificationCenter.default.post(
            name: NSNotification.Name("ThemeModeChanged"),
            object: nil,
            userInfo: ["themeMode": mode]
        )
    }
    
    /// Updates app language and triggers UI refresh
    func changeLanguage(to language: AppLanguage) {
        appLanguage = language
        UserDefaultsManager.shared.saveAppLanguage(language)
        
        // Post notification for all views to refresh locale-dependent content
        NotificationCenter.default.post(
            name: NSNotification.Name("AppLanguageChanged"),
            object: nil
        )
    }
    
    /// Toggles push notifications and manages permissions/scheduling
    func toggleNotifications() {
        notificationsEnabled.toggle()
        UserDefaultsManager.shared.saveNotificationsEnabled(notificationsEnabled)
        
        if notificationsEnabled {
            // Request permission and schedule if granted
            NotificationManager.shared.requestPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(at: self.notificationTime)
                } else {
                    // Revert state if permission is denied
                    DispatchQueue.main.async {
                        self.notificationsEnabled = false
                        UserDefaultsManager.shared.saveNotificationsEnabled(false)
                    }
                }
            }
        } else {
            // Remove all scheduled reminders
            NotificationManager.shared.cancelAllReminders()
        }
    }
    
    /// Updates notification time and reschedules the reminder
    func changeNotificationTime(to hour: Int) {
        notificationTime = hour
        UserDefaultsManager.shared.saveNotificationTime(hour)
        
        // Update scheduled notification if enabled
        if notificationsEnabled {
            NotificationManager.shared.scheduleDailyReminder(at: hour)
        }
    }
}
