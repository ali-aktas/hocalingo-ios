//
//  PremiumManager.swift
//  HocaLingo
//
//  ✅ PRODUCTION READY: Test mode removed, RevenueCat fully integrated
//  ✅ NEW: 3-launch paywall tracking for free users
//  Location: HocaLingo/Models/PremiumManager.swift
//

import Foundation
import Combine
import RevenueCat

// MARK: - Premium Manager
/// Singleton manager for premium status and features
/// ✅ Production ready with RevenueCat integration
class PremiumManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = PremiumManager()
    
    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let premiumKey = "user_is_premium"
    
    // MARK: - 3-Launch Paywall Tracking
    private let launchCountKey = "premium_paywall_launch_count"
    private let lastPaywallShownKey = "premium_paywall_last_shown"
    
    // MARK: - Initialization
    private init() {
        loadPremiumStatus()
        checkPremiumStatusWithRevenueCat()
    }
    
    // MARK: - Public Methods
    
    /// Load premium status from UserDefaults (backup)
    func loadPremiumStatus() {
        isPremium = userDefaults.bool(forKey: premiumKey)
        print("📱 Premium status loaded: \(isPremium ? "Premium" : "Free")")
    }
    
    /// Set premium status (for RevenueCat callbacks)
    /// - Parameter value: Premium status
    func setPremium(_ value: Bool) {
        isPremium = value
        userDefaults.set(value, forKey: premiumKey)
        print("✅ Premium status updated: \(value ? "Premium" : "Free")")
    }
    
    /// Check if user can access premium feature
    /// - Returns: True if premium
    func canAccessPremiumFeature() -> Bool {
        return isPremium
    }
    
    /// Check if package is accessible
    /// - Parameter isPremiumPackage: Is the package premium?
    /// - Returns: True if accessible
    func canAccessPackage(isPremiumPackage: Bool) -> Bool {
        return !isPremiumPackage || isPremium
    }
    
    // MARK: - RevenueCat Integration
    
    /// Check premium status with RevenueCat
    func checkPremiumStatusWithRevenueCat() {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ RevenueCat error: \(error.localizedDescription)")
                return
            }
            
            // Check if "premium" entitlement is active
            let isActive = customerInfo?.entitlements["premium"]?.isActive == true
            
            DispatchQueue.main.async {
                self.isPremium = isActive
                self.userDefaults.set(isActive, forKey: self.premiumKey)
                print("✅ RevenueCat premium status: \(isActive ? "Active" : "Inactive")")
            }
        }
    }
    
    /// Restore purchases
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] (customerInfo, error) in
            guard let self = self else {
                completion(false)
                return
            }
            
            if let error = error {
                print("❌ Restore error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            let isActive = customerInfo?.entitlements["premium"]?.isActive == true
            
            DispatchQueue.main.async {
                self.isPremium = isActive
                self.userDefaults.set(isActive, forKey: self.premiumKey)
                print("✅ Purchases restored. Premium: \(isActive)")
                completion(isActive)
            }
        }
    }
    
    /// Purchase a package
    /// - Parameters:
    ///   - package: RevenueCat package to purchase
    ///   - completion: Callback with success status and optional error message
    func purchasePackage(_ package: RevenueCat.Package, completion: @escaping (Bool, String?) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] (transaction, customerInfo, error, userCancelled) in
            guard let self = self else {
                completion(false, "Unknown error")
                return
            }
            
            if userCancelled {
                print("🚫 User cancelled purchase")
                DispatchQueue.main.async {
                    completion(false, nil)  // nil = user cancelled (no error message)
                }
                return
            }
            
            if let error = error {
                print("❌ Purchase error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            // Check if premium entitlement is now active
            let isActive = customerInfo?.entitlements["premium"]?.isActive == true
            
            DispatchQueue.main.async {
                self.isPremium = isActive
                self.userDefaults.set(isActive, forKey: self.premiumKey)
                print("✅ Purchase successful! Premium: \(isActive)")
                // Meta Event: subscription purchased
                if isActive {
                    MetaEventManager.shared.logSubscriptionStarted(price: 0, currency: "TRY")
                }
                completion(isActive, nil)
            }
        }
    }
    
    // MARK: - 3-Launch Paywall System
    
    /// Increment launch count and check if paywall should be shown
    /// Call this on app launch
    /// - Returns: True if paywall should be shown
    func shouldShowPaywallOnLaunch() -> Bool {
        // Premium users never see paywall
        if isPremium {
            return false
        }
        
        // Get current launch count
        let currentCount = userDefaults.integer(forKey: launchCountKey)
        let newCount = currentCount + 1
        userDefaults.set(newCount, forKey: launchCountKey)
        
        print("📱 App launch count (paywall): \(newCount)")
        
        // Show paywall every 3rd launch
        if newCount % 3 == 0 {
            // Update last shown timestamp
            userDefaults.set(Date(), forKey: lastPaywallShownKey)
            print("🎯 Paywall should be shown (3rd launch)")
            return true
        }
        
        return false
    }
    
    /// Reset paywall launch counter (for testing)
    func resetPaywallLaunchCounter() {
        userDefaults.set(0, forKey: launchCountKey)
        userDefaults.removeObject(forKey: lastPaywallShownKey)
        print("🔄 Paywall launch counter reset")
    }
    
    /// Get paywall launch statistics (for debugging)
    func getPaywallStats() -> (launchCount: Int, lastShown: Date?) {
        let count = userDefaults.integer(forKey: launchCountKey)
        let lastShown = userDefaults.object(forKey: lastPaywallShownKey) as? Date
        return (count, lastShown)
    }
}
