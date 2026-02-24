//
//  PremiumPaywallView.swift
//  HocaLingo
//
//  ✅ V3: Haftalık karşılaştırma, badge sağ üstte, iptal metni eklendi
//  Features/Premium/PremiumPaywallView.swift
//

import SwiftUI
import RevenueCat
import SafariServices

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
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Base background
                Color.themeBackground.ignoresSafeArea()
                
                imageHeaderBackground
                
                // Accent circles (AFTER image, so they're visible)
                Circle()
                    .fill(
                        Color(hex: "FFD700").opacity(
                            colorScheme == .dark ? 0.15 : 0.08
                        )
                    )
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .offset(x: -100, y: 300)
                    .allowsHitTesting(false)
                
                Circle()
                    .fill(
                        Color(hex: "FFA500").opacity(
                            colorScheme == .dark ? 0.12 : 0.06
                        )
                    )
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: 150, y: 600)
                    .allowsHitTesting(false)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 320)
                        VStack(spacing: 18) {
                            titleSection
                            featuresSection
                            
                            if currentOffering != nil {
                                pricingSection
                            } else {
                                ProgressView().padding()
                            }
                            
                            VStack(spacing: 16) {
                                purchaseButton
                                cancelAnytimeText
                                footerLinks
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        .padding(.bottom, 40)
                        .background(
                            LinearGradient(
                                colors: [Color.themeBackground.opacity(0), Color.themeBackground],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .padding(.top, -50)
                        )
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .black.opacity(0.4))
                    }
                }
            }
            .onAppear {
                fetchOfferings()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/privacy-policy.html")!)
            }
            .sheet(isPresented: $showTermsOfService) {
                SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/terms-of-service.html")!)
            }
        }
    }
    
    // MARK: - Image Header
    private var imageHeaderBackground: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image("paywall_image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height * 0.65, alignment: .top)
                    .clipped()
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.themeBackground.opacity(0),
                                Color.themeBackground.opacity(0.3),
                                Color.themeBackground
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 200)
            }
            .ignoresSafeArea()
        }
        .frame(height: UIScreen.main.bounds.height * 0.65)
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Premium ile Hızlan")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text("Tüm özelliklerin kilidini aç ve premium kalitede öğren!")
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 10) {
            featureLine(icon: "book.fill", text: "Binlerce Yeni Kelime")
            featureLine(icon: "infinity", text: "Sınırsız ve Premium Deneyim")
            featureLine(icon: "sparkles", text: "Sana Özel Okuma Parçaları")
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Feature Line
    private func featureLine(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
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
                    .frame(width: 24, height: 24)
                    .blur(radius: 6)
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
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .bold))
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.themePrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 10) {
            // Annual Plan FIRST (Best Value)
            if let annualPackage = getRevenueCatPackage(for: .annual) {
                pricingPlanCard(
                    plan: .annual,
                    package: annualPackage,
                    title: "Yıllık",
                    badge: "%90 İNDİRİM",
                    isSelected: selectedPlan == .annual
                )
            }
            
            // Weekly Plan SECOND
            if let weeklyPackage = getRevenueCatPackage(for: .weekly) {
                pricingPlanCard(
                    plan: .weekly,
                    package: weeklyPackage,
                    title: "Haftalık",
                    badge: nil,
                    isSelected: selectedPlan == .weekly
                )
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Get RevenueCat Package
    private func getRevenueCatPackage(for plan: PricingPlan) -> RevenueCat.Package? {
        guard let offering = currentOffering else { return nil }
        
        return offering.availablePackages.first { package in
            package.identifier == plan.packageIdentifier
        }
    }
    
    // MARK: - Pricing Plan Card
    private func pricingPlanCard(plan: PricingPlan, package: RevenueCat.Package, title: String, badge: String?, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedPlan = plan
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "FFD700") : .themeSecondary, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(hex: "FFD700"))
                            .frame(width: 12, height: 12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    if plan == .annual {
                        Text("Sadece yıllık \(package.storeProduct.localizedPriceString)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.themeSecondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(getWeeklyPriceString(package: package, plan: plan))
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    Text("/ hafta")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.themeSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? [
                                Color(hex: colorScheme == .dark ? "2A2A2A" : "F5F5F5"),
                                Color(hex: colorScheme == .dark ? "1F1F1F" : "ECECEC")
                            ] : [
                                Color(hex: colorScheme == .dark ? "1F1F1F" : "F8F8F8"),
                                Color(hex: colorScheme == .dark ? "1A1A1A" : "F0F0F0")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
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
            .overlay(
                Group {
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
                .offset(x: -8, y: -8),
                alignment: .topTrailing
            )
            .shadow(color: isSelected ? Color(hex: "FFD700").opacity(0.3) : Color.themeShadow.opacity(0.2), radius: isSelected ? 10 : 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helper: Get Weekly Price String
    private func getWeeklyPriceString(package: RevenueCat.Package, plan: PricingPlan) -> String {
        if plan == .annual, let period = package.storeProduct.subscriptionPeriod {
            let price = package.storeProduct.price as Decimal
            let weeklyPrice = price / (Decimal(period.value) * 52)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = package.storeProduct.priceFormatter?.currencyCode ?? "TRY"
            formatter.maximumFractionDigits = 2
            
            return formatter.string(from: weeklyPrice as NSNumber) ?? "\(weeklyPrice)"
        }
        
        return package.storeProduct.localizedPriceString
    }
    
    // MARK: - Calculate Weekly Equivalent (for display text only)
    private func calculateWeeklyEquivalent(package: RevenueCat.Package, period: SubscriptionPeriod) -> String {
        let price = package.storeProduct.price as Decimal
        let currencyCode = package.storeProduct.priceFormatter?.currencyCode ?? "TRY"
        
        if period.unit == .year {
            let weeklyPrice = price / (Decimal(period.value) * 52)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currencyCode
            formatter.maximumFractionDigits = 2
            
            let weeklyString = formatter.string(from: weeklyPrice as NSNumber) ?? "\(weeklyPrice)"
            return "\(weeklyString) / hafta"
        }
        
        return ""
    }
    
    // MARK: - Purchase Button
    private var purchaseButton: some View {
        Button(action: handlePurchase) {
            HStack(spacing: 12) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Devam Et")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
        .padding(.top, 6)
    }
    
    // MARK: - Cancel Anytime Text
    private var cancelAnytimeText: some View {
        Text("Dilediğin zaman iptal edebilirsin")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.themeSecondary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
    
    // MARK: - Footer Links
    private var footerLinks: some View {
        VStack(spacing: 10) {
            Button(action: handleRestore) {
                Text("paywall_restore")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.themeSecondary)
            }
            .disabled(isProcessing)
            
            HStack(spacing: 16) {
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
        .padding(.top, 6)
    }
    
    // MARK: - Actions
    
    private func fetchOfferings() {
        Purchases.shared.getOfferings { offerings, error in
            if let error = error {
                print("❌ Error fetching offerings: \(error.localizedDescription)")
                return
            }
            
            currentOffering = offerings?.current
            print("✅ Offerings fetched: \(currentOffering?.availablePackages.count ?? 0) packages")
        }
    }
    
    private func handlePurchase() {
        guard let package = getRevenueCatPackage(for: selectedPlan) else {
            print("❌ Package not found for selected plan")
            return
        }
        
        isProcessing = true
        
        premiumManager.purchasePackage(package) { success, errorMsg in
            isProcessing = false
            
            if success {
                print("✅ Purchase successful!")
                dismiss()
            } else if let errorMsg = errorMsg {
                errorMessage = errorMsg
                showError = true
                print("❌ Purchase failed: \(errorMsg)")
            } else {
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
        showTermsOfService = true
    }

    private func openPrivacy() {
        showPrivacyPolicy = true
    }
}

// MARK: - Pricing Plan Enum
enum PricingPlan: String {
    case weekly = "weekly"
    case annual = "annual"
    
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
#Preview {
    PremiumPaywallView()
        .preferredColorScheme(.dark)
}
