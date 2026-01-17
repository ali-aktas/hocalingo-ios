//
//  UserDefaultsManager+Home.swift
//  HocaLingo
//
//  Extensions for Home screen data management
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+Home.swift
//

import Foundation

// MARK: - Home Screen Extensions
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum HomeKeys {
        static let userName = "user_name"
        static let lastLaunchDate = "last_launch_date"
        static let monthlyStudiedDays = "monthly_studied_days"
    }
    
    // MARK: - User Name
    
    /// Save user name
    func saveUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: HomeKeys.userName)
    }
    
    /// Load user name
    func loadUserName() -> String? {
        return UserDefaults.standard.string(forKey: HomeKeys.userName)
    }
    
    // MARK: - Last Launch Date (for streak tracking)
    
    /// Save last app launch date
    func saveLastLaunchDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: HomeKeys.lastLaunchDate)
    }
    
    /// Load last app launch date
    func loadLastLaunchDate() -> Date {
        if let date = UserDefaults.standard.object(forKey: HomeKeys.lastLaunchDate) as? Date {
            return date
        }
        // Return yesterday if no record (so first launch creates streak of 1)
        return Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    }
    
    // MARK: - Monthly Studied Days (for calendar view)
    
    /// Save studied days for current month
    func saveMonthlyStudiedDays(_ days: [String]) {
        UserDefaults.standard.set(days, forKey: HomeKeys.monthlyStudiedDays)
    }
    
    /// Load studied days for current month
    func loadMonthlyStudiedDays() -> [String] {
        return UserDefaults.standard.array(forKey: HomeKeys.monthlyStudiedDays) as? [String] ?? []
    }
    
    /// Add today to studied days
    func markTodayAsStudied() {
        var days = loadMonthlyStudiedDays()
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        
        if !days.contains(String(today)) {
            days.append(String(today))
            saveMonthlyStudiedDays(days)
        }
    }
    
    /// Check if a specific date was studied
    func wasStudied(date: Date) -> Bool {
        let days = loadMonthlyStudiedDays()
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        return days.contains(String(dateString))
    }
    
    /// Clear monthly data (call at start of new month)
    func clearMonthlyData() {
        UserDefaults.standard.removeObject(forKey: HomeKeys.monthlyStudiedDays)
    }
}
