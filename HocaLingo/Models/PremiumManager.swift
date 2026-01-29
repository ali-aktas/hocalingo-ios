//
//  PremiumManager.swift
//  HocaLingo
//
//  Premium status management - Ready for RevenueCat integration
//  Location: HocaLingo/Models/PremiumManager.swift
//

import Foundation
import Combine

// MARK: - Premium Manager
/// Singleton manager for premium status and features
/// ✅ Phase 1: Simple UserDefaults flag (for testing)
/// ✅ Phase 2: RevenueCat integration (future)
class PremiumManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = PremiumManager()
    
    // MARK: - Published Properties
    @Published var isPremium: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let premiumKey = "user_is_premium"
    
    // MARK: - Initialization
    private init() {
        loadPremiumStatus()
    }
    
    // MARK: - Public Methods
    
    /// Load premium status from UserDefaults
    func loadPremiumStatus() {
        isPremium = userDefaults.bool(forKey: premiumKey)
        print("📱 Premium status loaded: \(isPremium ? "Premium" : "Free")")
    }
    
    /// Set premium status (for testing)
    /// - Parameter value: Premium status
    func setPremium(_ value: Bool) {
        isPremium = value
        userDefaults.set(value, forKey: premiumKey)
        print("✅ Premium status updated: \(value ? "Premium" : "Free")")
    }
    
    /// Toggle premium status (for testing)
    func togglePremium() {
        setPremium(!isPremium)
    }
    
    /// Check if user can access premium feature
    /// - Returns: True if premium or feature is free
    func canAccessPremiumFeature() -> Bool {
        return isPremium
    }
    
    /// Check if package is accessible
    /// - Parameter isPremiumPackage: Is the package premium?
    /// - Returns: True if accessible
    func canAccessPackage(isPremiumPackage: Bool) -> Bool {
        return !isPremiumPackage || isPremium
    }
    
    // MARK: - RevenueCat Integration (Future)
    
    /// Check premium status with RevenueCat
    /// ✅ TODO: Implement RevenueCat integration
    func checkPremiumStatusWithRevenueCat() {
        // Future implementation:
        // Purchases.shared.getCustomerInfo { (customerInfo, error) in
        //     self.isPremium = customerInfo?.entitlements["premium"]?.isActive == true
        // }
        print("⚠️ RevenueCat integration not yet implemented")
    }
    
    /// Restore purchases
    /// ✅ TODO: Implement RevenueCat restore
    func restorePurchases(completion: @escaping (Bool) -> Void) {
        // Future implementation:
        // Purchases.shared.restorePurchases { (customerInfo, error) in
        //     self.isPremium = customerInfo?.entitlements["premium"]?.isActive == true
        //     completion(self.isPremium)
        // }
        print("⚠️ RevenueCat restore not yet implemented")
        completion(false)
    }
}
