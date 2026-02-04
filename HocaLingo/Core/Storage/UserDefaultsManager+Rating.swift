//
//  UserDefaultsManager+Rating.swift
//  HocaLingo
//
//  App rating extension - Launch count tracking
//  Location: HocaLingo/Core/Storage/UserDefaultsManager+Rating.swift
//

import Foundation

// MARK: - Rating Extension
extension UserDefaultsManager {
    
    // MARK: - Keys
    private enum RatingKeys {
        static let launchCount = "app_launch_count"
        static let hasShownRating = "has_shown_rating"
    }
    
    // MARK: - Launch Count
    
    /// Increment launch count
    func incrementLaunchCount() {
        let currentCount = getLaunchCount()
        UserDefaults.standard.set(currentCount + 1, forKey: RatingKeys.launchCount)
        
        print("📱 App launch count: \(currentCount + 1)")
    }
    
    /// Get current launch count
    func getLaunchCount() -> Int {
        return UserDefaults.standard.integer(forKey: RatingKeys.launchCount)
    }
    
    // MARK: - Rating Status
    
    /// Check if rating dialog has been shown before
    func hasShownRating() -> Bool {
        return UserDefaults.standard.bool(forKey: RatingKeys.hasShownRating)
    }
    
    /// Mark rating dialog as shown
    func markRatingShown() {
        UserDefaults.standard.set(true, forKey: RatingKeys.hasShownRating)
        print("⭐ Rating dialog shown - will not show again")
    }
    
    /// Check if we should show rating (5th launch, not shown before)
    func shouldShowRating() -> Bool {
        let count = getLaunchCount()
        let hasShown = hasShownRating()
        
        return count == 5 && !hasShown
    }
}
