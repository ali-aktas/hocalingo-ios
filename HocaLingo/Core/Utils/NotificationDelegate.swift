//
//  NotificationDelegate.swift
//  HocaLingo
//
//  ✅ ENHANCED: Deep linking support for notification tap handling
//  Location: Core/Utils/NotificationDelegate.swift
//

import UserNotifications
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    // ✅ NEW: Notification tap callback
    var onNotificationTapped: ((String) -> Void)?
    
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
        // ✅ NEW: Handle notification tap with deep linking
        let userInfo = response.notification.request.content.userInfo
        
        // Get destination from userInfo
        if let destination = userInfo["destination"] as? String {
            print("📱 Notification tapped: destination = \(destination)")
            
            // Set flag for navigation
            if destination == "study" {
                UserDefaults.standard.set(true, forKey: "should_navigate_to_study")
            } else if destination == "ai" {
                UserDefaults.standard.set(true, forKey: "should_navigate_to_ai")
            }
            
            // Post notification for tab change
            NotificationCenter.default.post(
                name: NSNotification.Name("SwitchToTab"),
                object: destination
            )
        }
        
        
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Badge clear error: \(error)")
            }
        }
        
        completionHandler()
    }
}
