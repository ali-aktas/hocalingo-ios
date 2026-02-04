//
//  NotificationManager.swift
//  HocaLingo
//
//  ✅ ENHANCED: Multiple motivational messages, weekly AI notifications
//  ✅ NEW: First-time permission request, deep linking support
//  Location: Core/Utils/NotificationManager.swift
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Notification Identifiers
    private let dailyReminderIdentifier = "daily_study_reminder"
    private let weeklyAIReminderIdentifier = "weekly_ai_story_reminder"
    
    // MARK: - Permission Management
    
    /// Request notification permission on first launch (after onboarding)
    /// Call this from MainTabView.onAppear (first time only)
    func requestPermissionOnFirstLaunch(completion: @escaping (Bool) -> Void) {
        // Check if we already requested permission before
        let hasRequestedBefore = UserDefaults.standard.bool(forKey: "has_requested_notification_permission")
        
        if hasRequestedBefore {
            // Already requested, just check current status
            checkCurrentPermissionStatus(completion: completion)
            return
        }
        
        // First time requesting
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                // Mark as requested
                UserDefaults.standard.set(true, forKey: "has_requested_notification_permission")
                
                if granted {
                    print("✅ Notification permission granted on first launch")
                    // Auto-enable notifications
                    UserDefaultsManager.shared.saveNotificationsEnabled(true)
                    // Schedule with default time (9 AM)
                    self.scheduleDailyReminder(at: 9)
                    // Schedule weekly AI reminder
                    self.scheduleWeeklyAIReminder()
                } else {
                    print("❌ Notification permission denied")
                }
                
                completion(granted)
            }
        }
    }
    
    /// Check current permission status without requesting
    private func checkCurrentPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    /// Traditional permission request (for Profile toggle)
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Daily Study Reminders
    
    /// Schedule a daily reminder with random motivational message
    func scheduleDailyReminder(at hour: Int) {
        // Remove existing daily reminders
        cancelDailyReminders()
        
        // Pick a random message
        let message = getDailyReminderMessage()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_title", comment: "")
        content.body = message
        content.sound = .default
        content.badge = 1
        // ✅ Add userInfo for deep linking
        content.userInfo = ["destination": "study"]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        // Create repeating trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Add to system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Daily Notification Error: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled for \(hour):00")
            }
        }
    }
    
    /// Get a random motivational message for daily reminder
    private func getDailyReminderMessage() -> String {
        let messages = [
            NSLocalizedString("notification_msg_1", comment: ""),
            NSLocalizedString("notification_msg_2", comment: ""),
            NSLocalizedString("notification_msg_3", comment: ""),
            NSLocalizedString("notification_msg_4", comment: ""),
            NSLocalizedString("notification_msg_5", comment: ""),
            NSLocalizedString("notification_msg_6", comment: ""),
            NSLocalizedString("notification_msg_7", comment: ""),
            NSLocalizedString("notification_msg_8", comment: ""),
            NSLocalizedString("notification_msg_9", comment: ""),
            NSLocalizedString("notification_msg_10", comment: "")
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    /// Cancel daily reminders
    func cancelDailyReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        print("🚫 Daily reminders cancelled")
    }
    
    // MARK: - Weekly AI Story Reminders
    
    /// Schedule weekly AI story reminder (every Wednesday at 3 PM)
    /// This is automatically enabled when daily reminders are enabled
    func scheduleWeeklyAIReminder() {
        // Remove existing AI reminders
        cancelWeeklyAIReminder()
        
        // Pick a random AI message
        let message = getAIReminderMessage()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_ai_title", comment: "")
        content.body = message
        content.sound = .default
        content.badge = 1
        // ✅ Add userInfo for deep linking to AI screen
        content.userInfo = ["destination": "ai"]
        
        // Every Wednesday at 3 PM (15:00)
        var dateComponents = DateComponents()
        dateComponents.weekday = 4  // Wednesday (1 = Sunday, 4 = Wednesday)
        dateComponents.hour = 15
        dateComponents.minute = 0
        
        // Create weekly repeating trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: weeklyAIReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Add to system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ AI Notification Error: \(error.localizedDescription)")
            } else {
                print("✅ Weekly AI reminder scheduled for Wednesdays at 15:00")
            }
        }
    }
    
    /// Get a random AI story message
    private func getAIReminderMessage() -> String {
        let messages = [
            NSLocalizedString("notification_ai_msg_1", comment: ""),
            NSLocalizedString("notification_ai_msg_2", comment: ""),
            NSLocalizedString("notification_ai_msg_3", comment: ""),
            NSLocalizedString("notification_ai_msg_4", comment: ""),
            NSLocalizedString("notification_ai_msg_5", comment: "")
        ]
        
        return messages.randomElement() ?? messages[0]
    }
    
    /// Cancel weekly AI reminder
    func cancelWeeklyAIReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weeklyAIReminderIdentifier])
        print("🚫 Weekly AI reminder cancelled")
    }
    
    /// Cancel all reminders (daily + weekly AI)
    func cancelAllReminders() {
        cancelDailyReminders()
        cancelWeeklyAIReminder()
        print("🚫 All notifications cancelled")
    }
    
    // MARK: - Testing Helpers
    
    /// Schedule a test notification in 10 seconds (for debugging)
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification!"
        content.sound = .default
        content.userInfo = ["destination": "study"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification error: \(error)")
            } else {
                print("✅ Test notification scheduled in 10 seconds")
            }
        }
    }
}
