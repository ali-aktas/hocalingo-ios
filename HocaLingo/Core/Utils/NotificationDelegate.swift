//
//  NotificationDelegate.swift
//  HocaLingo
//
//  ✅ NEW: Handles notification behavior when app is in foreground
//  Location: Core/Utils/NotificationDelegate.swift
//

import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    /// Called when a notification is delivered to a foreground app
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner, play sound and update badge even if the app is active
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    /// Called when a user interacts with a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification click (e.g., navigate to specific view) if needed
        completionHandler()
    }
}
