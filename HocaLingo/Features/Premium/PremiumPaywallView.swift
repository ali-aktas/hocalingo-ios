//
//  PremiumPaywallView.swift
//  HocaLingo
//
//  ✅ V2: Full-width image, gradient pricing, side-by-side prices
//  Features/Premium/PremiumPaywallView.swift
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
            ZStack(alignment: .top) {
                Color.themeBackground.ignoresSafeArea()
                
                imageHeaderBackground
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 320)
                        VStack(spacing: 24) {
                            titleSection
                            featuresSection
                            
                            // Fiyatların yüklendiği kontrol noktası
                            if currentOffering != nil {
                                pricingSection
                            } else {
                                ProgressView().padding()
                            }
                            
                            VStack(spacing: 16) {
                                purchaseButton
                                footerLinks
                            }
                        }
                        .padding(.horizontal, 24)
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
            // ✨ EKSİK OLAN KRİTİK KISIM BURASI:
            .onAppear {
                fetchOfferings()
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        ZStack {
            // Base background
            Color.themeBackground
                .ignoresSafeArea()
            
            // Subtle gradient accents
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFD700").opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "FFA500").opacity(0.08),
                            Color.clear
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
    
    // MARK: - Image
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

    // MARK: - Başlık Bölümü
    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Premium Üyesi Ol")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text("Tüm özelliklerin kilidini aç ve premium kalitede öğren!")
                .font(.system(size: 16))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section (4 simple lines)
    private var featuresSection: some View {
        VStack(spacing: 10) { // 12 → 10
            featureLine(text: "Binlerce Yeni Kelime ve Kalıp Öğren")
            featureLine(text: "Günlük Sınırsız Kelime Seçme Hakkı")
            featureLine(text: "Aylık 30 Yapay Zeka Kullanma Hakkı")
            featureLine(text: "Premium Kart Tasarımları")
        }
        .padding(.vertical, 8) // 12 → 8
    }
    
    // MARK: - Feature Line
    private func featureLine(text: String) -> some View {
        HStack(spacing: 12) {
            // Gold crown icon with glow
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
                    .frame(width: 28, height: 28)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Feature text
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
        VStack(spacing: 10) { // 12 → 10
            // Weekly Plan
            if let weeklyPackage = getRevenueCatPackage(for: .weekly) {
                pricingPlanCard(
                    plan: .weekly,
                    package: weeklyPackage,
                    title: "Haftalık",
                    badge: nil,
                    isSelected: selectedPlan == .weekly
                )
            }
            
            // Annual Plan (Best Value)
            if let annualPackage = getRevenueCatPackage(for: .annual) {
                pricingPlanCard(
                    plan: .annual,
                    package: annualPackage,
                    title: "Yıllık",
                    badge: "En İyi Fiyat",
                    isSelected: selectedPlan == .annual
                )
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Get RevenueCat Package Helper
    private func getRevenueCatPackage(for plan: PricingPlan) -> RevenueCat.Package? {
        guard let offering = currentOffering else { return nil }
        
        return offering.availablePackages.first { package in
            package.identifier == plan.packageIdentifier
        }
    }
    
    // MARK: - Pricing Plan Card (YENİ TASARIM)
    private func pricingPlanCard(plan: PricingPlan, package: RevenueCat.Package, title: String, badge: String?, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedPlan = plan
            }
        }) {
            HStack(spacing: 12) {
                // Selection Circle
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
                
                // Plan Details
                VStack(alignment: .leading, spacing: 2) {
                    // Title + Price (YAN YANA)
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        Text(package.storeProduct.localizedPriceString)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        Spacer()
                        
                        // Badge
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
                    
                    // Monthly equivalent (ALTTA)
                    if let period = package.storeProduct.subscriptionPeriod {
                        Text(calculateMonthlyEquivalent(package: package, period: period))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.themeSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12) // 16 → 12 (daha ince)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        // ✨ GRADIENT ARKAPLAN
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
            .shadow(color: isSelected ? Color(hex: "FFD700").opacity(0.3) : Color.themeShadow.opacity(0.2), radius: isSelected ? 10 : 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Calculate Monthly Equivalent
    private func calculateMonthlyEquivalent(package: RevenueCat.Package, period: SubscriptionPeriod) -> String {
        let price = package.storeProduct.price as Decimal
        let currencyCode = package.storeProduct.priceFormatter?.currencyCode ?? "TRY"
        
        // Calculate monthly equivalent based on period
        let monthlyPrice: Decimal
        switch period.unit {
        case .day:
            monthlyPrice = (price * 30) / Decimal(period.value)
        case .week:
            monthlyPrice = (price * 52) / (Decimal(period.value) * 12)
        case .month:
            monthlyPrice = price / Decimal(period.value)
        case .year:
            monthlyPrice = price / (Decimal(period.value) * 12)
        @unknown default:
            monthlyPrice = price
        }
        
        // Format as currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        
        let monthlyString = formatter.string(from: monthlyPrice as NSNumber) ?? "\(monthlyPrice)"
        
        // Return formatted string
        return "≈ \(monthlyString) / ay"
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
            .padding(.vertical, 16) // 18 → 16
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
    
    // MARK: - Footer Links
    private var footerLinks: some View {
        VStack(spacing: 10) { // 12 → 10
            // Restore Purchases
            Button(action: handleRestore) {
                Text("paywall_restore")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.themeSecondary)
            }
            .disabled(isProcessing)
            
            // Legal Links
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
