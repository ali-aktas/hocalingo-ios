//
//  PremiumManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Full RevenueCat integration complete
//  Premium status management with RevenueCat SDK
//  Location: HocaLingo/Models/PremiumManager.swift
//

import Foundation
import Combine
import RevenueCat

// MARK: - Premium Manager
/// Singleton manager for premium status and features
/// ✅ Now fully integrated with RevenueCat
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
        
        // ✅ Check RevenueCat status on app launch
        checkPremiumStatusWithRevenueCat()
        
        // ✅ TEST MODE: Auto-set premium for testing
        #if DEBUG
        setPremium(true)
        print("🧪 TEST MODE: Premium activated for testing")
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Load premium status from UserDefaults (backup)
    func loadPremiumStatus() {
        isPremium = userDefaults.bool(forKey: premiumKey)
        print("📱 Premium status loaded: \(isPremium ? "Premium" : "Free")")
    }
    
    /// Set premium status (for testing and local storage)
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
    
    // MARK: - RevenueCat Integration
    
    /// Check premium status with RevenueCat
    /// ✅ IMPLEMENTED: Real RevenueCat integration
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
    /// ✅ IMPLEMENTED: Real RevenueCat restore
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
    /// ✅ NEW: Purchase implementation with RevenueCat
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
                completion(isActive, nil)
            }
        }
    }
}
