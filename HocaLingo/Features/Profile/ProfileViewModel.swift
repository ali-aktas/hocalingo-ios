import SwiftUI
import Combine

// MARK: - Profile ViewModel
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userStats: UserStats = .dummy
    @Published var isPremium: Bool = false
    @Published var themeMode: ThemeMode = .system
    @Published var notificationsEnabled: Bool = true
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var dailyGoal: Int = 20
    
    // MARK: - Initialization
    init() {
        loadSettings()
    }
    
    // MARK: - Settings Management
    
    /// Load user settings from UserDefaults
    private func loadSettings() {
        // Load theme mode
        if let themeModeString = UserDefaults.standard.string(forKey: "themeMode"),
           let mode = ThemeMode(rawValue: themeModeString) {
            themeMode = mode
        }
        
        // Load notifications
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        
        // Load study direction
        if let directionString = UserDefaults.standard.string(forKey: "studyDirection"),
           let direction = StudyDirection(rawValue: directionString) {
            studyDirection = direction
        }
        
        // Load daily goal
        let savedGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        if savedGoal > 0 {
            dailyGoal = savedGoal
        }
    }
    
    /// Save settings to UserDefaults
    private func saveSettings() {
        UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(studyDirection.rawValue, forKey: "studyDirection")
        UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
    }
    
    // MARK: - Public Actions
    
    /// Update theme mode
    func updateThemeMode(_ mode: ThemeMode) {
        themeMode = mode
        saveSettings()
    }
    
    /// Toggle notifications
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        saveSettings()
        
        if enabled {
            // TODO: Schedule notifications in Day 7
            print("📱 Notifications enabled")
        } else {
            // TODO: Cancel notifications in Day 7
            print("🔕 Notifications disabled")
        }
    }
    
    /// Update study direction
    func updateStudyDirection(_ direction: StudyDirection) {
        studyDirection = direction
        saveSettings()
    }
    
    /// Update daily goal
    func updateDailyGoal(_ goal: Int) {
        dailyGoal = goal
        saveSettings()
    }
    
    /// Refresh profile data
    func refresh() {
        // TODO: Reload user stats from database in Day 7
        print("🔄 Refreshing profile data...")
    }
}
