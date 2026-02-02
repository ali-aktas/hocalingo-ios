//
//  PremiumPaywallView.swift
//  HocaLingo
//
//  ✅ FIXED: Proper namespace for RevenueCat.Package to avoid conflicts
//  Location: HocaLingo/Features/Premium/PremiumPaywallView.swift
//

import SwiftUI
import RevenueCat

// MARK: - Premium Paywall View
struct PremiumPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var premiumManager = PremiumManager.shared
    
    @State private var selectedPlan: PricingPlan = .annual
    @State private var isProcessing: Bool = false
    @State private var currentOffering: Offering?
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Header
                        headerSection
                        
                        // Features
                        featuresSection
                        
                        // Pricing Plans
                        if currentOffering != nil {
                            pricingSection
                        } else {
                            // Loading indicator while fetching offerings
                            ProgressView()
                                .padding()
                        }
                        
                        // Purchase Button
                        purchaseButton
                        
                        // Restore & Legal Links
                        footerLinks
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "Unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            loadOfferings()
        }
    }
    
    // MARK: - Load Offerings
    private func loadOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print("❌ Error loading offerings: \(error.localizedDescription)")
                return
            }
            
            if let offering = offerings?.current {
                currentOffering = offering
                print("✅ Offerings loaded: \(offering.availablePackages.count) packages")
            } else {
                print("⚠️ No current offering found")
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            Color.themeBackground
                .ignoresSafeArea()
            
            // Animated gradient circles
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFD700").opacity(0.15),
                            Color(hex: "FFA500").opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFA500").opacity(0.12),
                            Color(hex: "FFD700").opacity(0.06)
                        ],
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 150, y: 300)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Crown Icon with Glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700"),
                                Color(hex: "FFA500")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .blur(radius: 25)
                    .opacity(0.6)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700"),
                                Color(hex: "FFA500")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            // Title & Subtitle
            VStack(spacing: 12) {
                Text("paywall_title")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .multilineTextAlignment(.center)
                
                Text("paywall_subtitle")
                    .font(.system(size: 17))
                    .foregroundColor(.themeSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 16) {
            premiumFeature(
                icon: "infinity",
                iconColor: Color(hex: "4ECDC4"),
                title: "paywall_feature_1",
                description: "No daily limits on word selection"
            )
            
            premiumFeature(
                icon: "app.badge.checkmark.fill",
                iconColor: Color(hex: "10B981"),
                title: "paywall_feature_2",
                description: "Study without interruptions"
            )
            
            premiumFeature(
                icon: "sparkles",
                iconColor: Color(hex: "FFD700"),
                title: "paywall_feature_3",
                description: "Business, Tech, Medical & more"
            )
            
            premiumFeature(
                icon: "brain.head.profile",
                iconColor: Color(hex: "8B5CF6"),
                title: "paywall_feature_4",
                description: "Personalized reading passages"
            )
        }
        .padding(20)
        .background(Color.themeCard)
        .cornerRadius(20)
        .shadow(color: Color.themeShadow, radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Feature Row
    private func premiumFeature(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(iconColor)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(title))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.themeSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Weekly Plan
            if let weeklyPackage = getRevenueCatPackage(for: .weekly) {
                pricingPlanCard(
                    plan: .weekly,
                    package: weeklyPackage,
                    title: "paywall_plan_weekly",
                    badge: nil,
                    isSelected: selectedPlan == .weekly
                )
            }
            
            // Annual Plan (Best Value)
            if let annualPackage = getRevenueCatPackage(for: .annual) {
                pricingPlanCard(
                    plan: .annual,
                    package: annualPackage,
                    title: "paywall_plan_yearly",
                    badge: "paywall_best_value",
                    isSelected: selectedPlan == .annual
                )
            }
        }
    }
    
    // MARK: - Get RevenueCat Package Helper
    // ✅ FIXED: Return type explicitly set to RevenueCat.Package
    private func getRevenueCatPackage(for plan: PricingPlan) -> RevenueCat.Package? {
        guard let offering = currentOffering else { return nil }
        
        // Find package by identifier
        return offering.availablePackages.first { package in
            package.identifier == plan.packageIdentifier
        }
    }
    
    // MARK: - Pricing Plan Card
    // ✅ FIXED: Parameter type explicitly set to RevenueCat.Package
    private func pricingPlanCard(plan: PricingPlan, package: RevenueCat.Package, title: String, badge: String?, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedPlan = plan
            }
        }) {
            HStack(spacing: 16) {
                // Selection Circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "FFD700") : Color.themeSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "FFD700"))
                            .frame(width: 14, height: 14)
                    }
                }
                
                // Plan Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        if let badge = badge {
                            Text(LocalizedStringKey(badge))
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "10B981"))
                                )
                        }
                    }
                    
                    // Free trial info if available
                    if let introPrice = package.storeProduct.introductoryDiscount {
                        Text("\(introPrice.subscriptionPeriod.periodTitle) free trial")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "10B981"))
                    }
                }
                
                Spacer()
                
                // Price
                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? Color(hex: "FFD700") : .themeSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ?
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "FFD700"),
                                            Color(hex: "FFA500")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .shadow(color: isSelected ? Color(hex: "FFD700").opacity(0.3) : Color.themeShadow, radius: isSelected ? 12 : 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Purchase Button
    private var purchaseButton: some View {
        Button(action: handlePurchase) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "crown.fill")
                    Text("paywall_purchase_button")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "FFD700"),
                        Color(hex: "FFA500")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 15, y: 8)
        }
        .disabled(isProcessing || currentOffering == nil)
    }
    
    // MARK: - Footer Links
    private var footerLinks: some View {
        VStack(spacing: 16) {
            // Restore Purchases
            Button(action: handleRestore) {
                Text("paywall_restore")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.themeSecondary)
            }
            .disabled(isProcessing)
            
            // Legal Links
            HStack(spacing: 20) {
                Button(action: openTerms) {
                    Text("paywall_terms")
                        .font(.system(size: 13))
                        .foregroundColor(.themeTertiary)
                }
                
                Text("•")
                    .foregroundColor(.themeTertiary)
                
                Button(action: openPrivacy) {
                    Text("paywall_privacy")
                        .font(.system(size: 13))
                        .foregroundColor(.themeTertiary)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func handlePurchase() {
        // ✅ FIXED: Explicitly get RevenueCat.Package
        guard let package = getRevenueCatPackage(for: selectedPlan) else {
            print("❌ Package not found for selected plan")
            return
        }
        
        isProcessing = true
        
        // ✅ Real RevenueCat purchase
        premiumManager.purchasePackage(package) { success, errorMsg in
            isProcessing = false
            
            if success {
                print("✅ Purchase successful!")
                dismiss()
            } else if let errorMsg = errorMsg {
                // Show error (not user cancelled)
                errorMessage = errorMsg
                showError = true
                print("❌ Purchase failed: \(errorMsg)")
            } else {
                // User cancelled, do nothing
                print("🚫 User cancelled purchase")
            }
        }
    }
    
    private func handleRestore() {
        isProcessing = true
        
        premiumManager.restorePurchases { success in
            isProcessing = false
            
            if success {
                print("✅ Purchases restored successfully!")
                dismiss()
            } else {
                errorMessage = "No purchases found to restore"
                showError = true
                print("⚠️ No purchases to restore")
            }
        }
    }
    
    private func openTerms() {
        if let url = URL(string: "https://www.hocalingo.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacy() {
        if let url = URL(string: "https://www.hocalingo.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Pricing Plan Enum
enum PricingPlan: String {
    case weekly = "weekly"
    case annual = "annual"
    
    // ✅ FIX: RevenueCat identifier'larını eşleştir
    var packageIdentifier: String {
        switch self {
        case .weekly: return "$rc_weekly"
        case .annual: return "$rc_annual"
        }
    }
}
// MARK: - SubscriptionPeriod Extension
extension SubscriptionPeriod {
    var periodTitle: String {
        let unitString: String
        switch self.unit {
        case .day:
            unitString = value == 1 ? "day" : "days"
        case .week:
            unitString = value == 1 ? "week" : "weeks"
        case .month:
            unitString = value == 1 ? "month" : "months"
        case .year:
            unitString = value == 1 ? "year" : "years"
        @unknown default:
            unitString = "period"
        }
        return "\(value) \(unitString)"
    }
}

// MARK: - Preview
struct PremiumPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PremiumPaywallView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            PremiumPaywallView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
