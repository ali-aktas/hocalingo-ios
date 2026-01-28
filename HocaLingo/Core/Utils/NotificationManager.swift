//
//  NotificationManager.swift
//  HocaLingo
//
//  ✅ NEW: Centralized manager for scheduling daily reminders
//  Location: Core/Utils/NotificationManager.swift
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    /// Requests permission and schedules if already enabled
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Schedules a daily reminder at a specific hour
    func scheduleDailyReminder(at hour: Int) {
        // First, remove existing notifications to avoid duplicates
        cancelAllReminders()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_title", comment: "")
        content.body = NSLocalizedString("notification_body", comment: "")
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        // Create repeating trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "daily_study_reminder",
            content: content,
            trigger: trigger
        )
        
        // Add to system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification Error: \(error.localizedDescription)")
            } else {
                print("✅ Daily reminder scheduled for \(hour):00")
            }
        }
    }
    
    /// Cancels the scheduled reminder
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_study_reminder"])
        print("🚫 Notification reminder cancelled")
    }
}
