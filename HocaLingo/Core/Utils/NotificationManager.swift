//
//  NotificationManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Alternating notifications — word reminders & motivational messages
//  ✅ Schedules 7 individual daily notifications instead of one repeating
//  ✅ Odd days = random word from vault, Even days = motivational message
//  ✅ Refreshes on every app open for fresh content
//  Location: Core/Utils/NotificationManager.swift
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Notification Identifiers
    private let dailyReminderPrefix = "daily_reminder_day_"  // day_0 through day_6
    private let weeklyAIReminderIdentifier = "weekly_ai_story_reminder"
    
    // MARK: - Permission Management
    
    /// Request notification permission on first launch (after onboarding)
    /// Call this from MainTabView.onAppear (first time only)
    func requestPermissionOnFirstLaunch(completion: @escaping (Bool) -> Void) {
        let hasRequestedBefore = UserDefaults.standard.bool(forKey: "has_requested_notification_permission")
        
        if hasRequestedBefore {
            checkCurrentPermissionStatus(completion: completion)
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "has_requested_notification_permission")
                
                if granted {
                    print("✅ Notification permission granted on first launch")
                    UserDefaultsManager.shared.saveNotificationsEnabled(true)
                    // Schedule with default time (1 PM / 13:00)
                    self.scheduleDailyReminder(at: 13)
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
    
    // MARK: - Daily Study Reminders (Alternating Word / Motivation)
    
    /// Schedule 7 days of alternating notifications
    /// Odd days (1,3,5,7) = word from vault with translation
    /// Even days (2,4,6) = motivational message
    /// Called on every app open to keep content fresh
    func scheduleDailyReminder(at hour: Int) {
        // Remove all existing daily reminders
        cancelDailyReminders()
        
        // Get random words from vault for word-type notifications
        let vaultWords = getRandomVaultWords(count: 4) // Need 4 word slots (days 1,3,5,7)
        
        // Determine starting type based on stored state
        // We toggle daily: true = word day, false = motivation day
        let lastType = UserDefaults.standard.string(forKey: "last_notification_type") ?? "motivation"
        var isWordDay = (lastType == "motivation") // Start with opposite of last
        
        var wordIndex = 0
        
        for dayOffset in 1...7 {
            let content = UNMutableNotificationContent()
            content.sound = .default
            content.badge = 1
            content.userInfo = ["destination": "study"]
            
            if isWordDay, wordIndex < vaultWords.count {
                // WORD NOTIFICATION: Show a word and its translation
                let word = vaultWords[wordIndex]
                content.title = NSLocalizedString("notification_word_title", comment: "")
                content.body = "📖 \(word.english) → \(word.turkish)"
                wordIndex += 1
            } else {
                // MOTIVATION NOTIFICATION: Random motivational message
                content.title = NSLocalizedString("notification_title", comment: "")
                content.body = getDailyReminderMessage()
            }
            
            // Calculate trigger date: today + dayOffset at specified hour
            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
            )
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            // Non-repeating trigger for this specific day
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "\(dailyReminderPrefix)\(dayOffset)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Notification Error (day \(dayOffset)): \(error.localizedDescription)")
                } else {
                    let type = isWordDay ? "📖 WORD" : "💪 MOTIVATION"
                    print("✅ Day \(dayOffset) [\(type)] scheduled for \(hour):00")
                }
            }
            
            // Alternate for next day
            isWordDay.toggle()
        }
        
        // Save the type of the LAST scheduled notification so next refresh continues correctly
        // Day 7's type determines what day 1 should be next time
        let finalType = ((lastType == "motivation") != (7 % 2 == 0)) ? "word" : "motivation"
        UserDefaults.standard.set(finalType, forKey: "last_notification_type")
        
        print("✅ 7-day alternating notification schedule set for \(hour):00")
    }
    
    // MARK: - Vault Word Fetching
    
    /// Represents a simple word pair for notifications
    private struct NotificationWord {
        let english: String
        let turkish: String
    }
    
    /// Fetch random words from the user's word vault
    /// Falls back to hardcoded words if vault is empty
    private func getRandomVaultWords(count: Int) -> [NotificationWord] {
        var allWords: [NotificationWord] = []
        
        // Load selected word IDs
        let selectedIds = Set(UserDefaultsManager.shared.loadSelectedWords())
        
        guard !selectedIds.isEmpty else {
            return getFallbackWords(count: count)
        }
        
        // Load words from all known package files
        let packageFiles = ["standard_a1_001", "standard_a1_002", "standard_a2_001",
                            "standard_b1_001", "standard_b2_001", "standard_c1_001"]
        
        let jsonLoader = JSONLoader()
        for packageId in packageFiles {
            if let package = try? jsonLoader.loadVocabularyPackage(filename: packageId) {
                let matchingWords = package.words
                    .filter { selectedIds.contains($0.id) }
                    .map { NotificationWord(english: $0.english, turkish: $0.turkish) }
                allWords.append(contentsOf: matchingWords)
            }
        }
        
        // Also include user-added words
        let userWords = UserDefaultsManager.shared.loadUserAddedWords()
            .filter { selectedIds.contains($0.id) }
            .map { NotificationWord(english: $0.english, turkish: $0.turkish) }
        allWords.append(contentsOf: userWords)
        
        guard !allWords.isEmpty else {
            return getFallbackWords(count: count)
        }
        
        // Shuffle and pick requested count
        return Array(allWords.shuffled().prefix(count))
    }
    
    /// Fallback words if vault is empty (user hasn't selected any words yet)
    private func getFallbackWords(count: Int) -> [NotificationWord] {
        let fallback: [NotificationWord] = [
            NotificationWord(english: "Hello", turkish: "Merhaba"),
            NotificationWord(english: "Thank you", turkish: "Teşekkür ederim"),
            NotificationWord(english: "Goodbye", turkish: "Hoşça kal"),
            NotificationWord(english: "Please", turkish: "Lütfen"),
            NotificationWord(english: "Friend", turkish: "Arkadaş"),
            NotificationWord(english: "Water", turkish: "Su"),
            NotificationWord(english: "Love", turkish: "Aşk"),
            NotificationWord(english: "Book", turkish: "Kitap")
        ]
        return Array(fallback.shuffled().prefix(count))
    }
    
    // MARK: - Motivational Messages
    
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
    
    /// Cancel all 7 daily reminders
    func cancelDailyReminders() {
        let identifiers = (1...7).map { "\(dailyReminderPrefix)\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🚫 Daily reminders cancelled (7 days)")
    }
    
    // MARK: - Weekly AI Story Reminders
    
    /// Schedule weekly AI story reminder (every Wednesday at 3 PM)
    /// This is automatically enabled when daily reminders are enabled
    func scheduleWeeklyAIReminder() {
        cancelWeeklyAIReminder()
        
        let message = getAIReminderMessage()
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification_ai_title", comment: "")
        content.body = message
        content.sound = .default
        content.badge = 1
        content.userInfo = ["destination": "ai"]
        
        // Every Wednesday at 3 PM (15:00)
        var dateComponents = DateComponents()
        dateComponents.weekday = 4  // Wednesday (1 = Sunday, 4 = Wednesday)
        dateComponents.hour = 15
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: weeklyAIReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
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
    
    // MARK: - Refresh on App Open
    
    /// Call this on every app open to refresh notification content
    /// Ensures fresh words and messages are always scheduled
    func refreshDailyRemindersIfNeeded() {
        let isEnabled = UserDefaultsManager.shared.loadNotificationsEnabled()
        guard isEnabled else { return }
        
        let hour = UserDefaultsManager.shared.loadNotificationTime()
        scheduleDailyReminder(at: hour)
        print("🔄 Daily reminders refreshed on app open")
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
