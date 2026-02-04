//
//  RatingManager.swift
//  HocaLingo
//
//  App rating manager - Handles app store rating prompt
//  Location: HocaLingo/Core/Utils/RatingManager.swift
//

import Foundation
import StoreKit
import SwiftUI

// MARK: - Rating Manager
/// Manages app store rating prompt
/// Shows native iOS rating dialog on 5th app launch
class RatingManager {
    
    // MARK: - Singleton
    static let shared = RatingManager()
    
    private init() {}
    
    // MARK: - Storage
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Main Function
    
    /// Check and show rating prompt if conditions are met
    /// Call this on app launch (MainTabView.onAppear)
    func checkAndShowRating() {
        // Increment launch count
        userDefaults.incrementLaunchCount()
        
        // Check if we should show rating
        guard userDefaults.shouldShowRating() else {
            let count = userDefaults.getLaunchCount()
            print("⭐ Rating check: Launch \(count)/5 - Not showing yet")
            return
        }
        
        // Show rating prompt
        showRatingPrompt()
        
        // Mark as shown (only show once)
        userDefaults.markRatingShown()
    }
    
    // MARK: - Private Helpers
    
    /// Show native iOS rating prompt
    private func showRatingPrompt() {
        // Add small delay for better UX (let UI settle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Get current window scene
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive })
                as? UIWindowScene {
                
                // Show native rating prompt
                SKStoreReviewController.requestReview(in: scene)
                
                print("⭐⭐⭐ RATING PROMPT SHOWN ⭐⭐⭐")
            }
        }
    }
    
    // MARK: - Manual Trigger (for testing)
    
    /// Force show rating prompt (for testing purposes)
    /// Usage: RatingManager.shared.forceShowRating()
    func forceShowRating() {
        showRatingPrompt()
    }
    
    /// Reset rating status (for testing)
    /// Usage: RatingManager.shared.resetRating()
    func resetRating() {
        UserDefaults.standard.set(0, forKey: "app_launch_count")
        UserDefaults.standard.set(false, forKey: "has_shown_rating")
        print("🔄 Rating status reset")
    }
}
