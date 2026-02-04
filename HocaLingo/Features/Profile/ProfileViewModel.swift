//
//  ProfileViewModel.swift
//  HocaLingo
//
//  ✅ ENHANCED: Weekly AI notification management
//  Location: Features/Profile/ProfileViewModel.swift
//

import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var appLanguage: AppLanguage = .english
    @Published var themeMode: ThemeMode = .system
    @Published var notificationsEnabled: Bool = false
    @Published var notificationTime: Int = 9  // Default 9 AM
    @Published var annualStats: AnnualStats = .empty
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    private let premiumManager = PremiumManager.shared
    
    // MARK: - Initialization
    init() {
        loadSettings()
        loadAnnualStats()
    }
    
    // MARK: - Load Settings
    private func loadSettings() {
        isPremium = premiumManager.isPremium
        studyDirection = userDefaults.loadStudyDirection()
        appLanguage = userDefaults.loadAppLanguage()
        themeMode = userDefaults.loadThemeMode()
        notificationsEnabled = userDefaults.loadNotificationsEnabled()
        notificationTime = userDefaults.loadNotificationTime()
    }
    
    // MARK: - Load Annual Stats
    private func loadAnnualStats() {
        annualStats = userDefaults.loadAnnualStats()
    }
    
    // MARK: - Settings Updates
    
    /// Changes study direction and saves to UserDefaults
    func changeStudyDirection(to direction: StudyDirection) {
        studyDirection = direction
        userDefaults.saveStudyDirection(direction)
        
        // Notify other views to refresh
        NotificationCenter.default.post(
            name: NSNotification.Name("StudyDirectionChanged"),
            object: nil
        )
    }
    
    /// Changes theme mode and saves to UserDefaults
    func changeThemeMode(to mode: ThemeMode) {
        themeMode = mode
        userDefaults.saveThemeMode(mode)
    }
    
    /// Changes app language and triggers UI refresh
    func changeLanguage(to language: AppLanguage) {
        appLanguage = language
        userDefaults.saveAppLanguage(language)
        
        // Post notification for all views to refresh locale-dependent content
        NotificationCenter.default.post(
            name: NSNotification.Name("AppLanguageChanged"),
            object: nil
        )
    }
    
    /// Toggles push notifications and manages permissions/scheduling
    func toggleNotifications() {
        notificationsEnabled.toggle()
        userDefaults.saveNotificationsEnabled(notificationsEnabled)
        
        if notificationsEnabled {
            // Request permission and schedule if granted
            NotificationManager.shared.requestPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    // Schedule daily reminder
                    NotificationManager.shared.scheduleDailyReminder(at: self.notificationTime)
                    // ✅ NEW: Schedule weekly AI reminder
                    NotificationManager.shared.scheduleWeeklyAIReminder()
                } else {
                    // Revert state if permission is denied
                    DispatchQueue.main.async {
                        self.notificationsEnabled = false
                        self.userDefaults.saveNotificationsEnabled(false)
                    }
                }
            }
        } else {
            // ✅ UPDATED: Remove all scheduled reminders (daily + AI)
            NotificationManager.shared.cancelAllReminders()
        }
    }
    
    /// Updates notification time and reschedules the reminder
    func changeNotificationTime(to hour: Int) {
        notificationTime = hour
        userDefaults.saveNotificationTime(hour)
        
        // Update scheduled notification if enabled
        if notificationsEnabled {
            // Reschedule daily reminder with new time
            NotificationManager.shared.scheduleDailyReminder(at: hour)
            // Note: Weekly AI reminder time is fixed (3 PM Wednesday), no need to reschedule
        }
    }
}
