//
//  PackageSelectionView.swift
//  HocaLingo
//
//  🔴 FULL REDESIGN:
//     - Custom back button on its own row (no auto-generated)
//     - Full-width tab selector with animated sliding indicator
//     - Clean themeBackground (no gradient/blur circle)
//     - Compact header with package count info
//     - Unified card layout for both standard and premium
//  ✅ PRESERVED: All navigation (WordSelectionView, PremiumPaywallView)
//  ✅ PRESERVED: handlePackageSelection logic, empty package overlay
//  ✅ PRESERVED: All @Binding, @Environment, @AppStorage
//
//  Location: HocaLingo/Features/Selection/PackageSelectionView.swift
//

import SwiftUI

// MARK: - Package Selection View
struct PackageSelectionView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = PackageSelectionViewModel()
    @State private var selectedPackageForNavigation: String? = nil
    @State private var currentTab: Int = 0 // 0 = Standard, 1 = Premium
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    @AppStorage("app_language") private var appLanguageCode: String = "en"
    
    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    // Gold accent color for premium elements
    private let goldColor = Color(hex: "FFD700")
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Clean background — matches app-wide themeBackground
                Color.themeBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom back button row
                    backButtonRow
                    
                    // Full-width tab selector
                    tabSelector
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    // Tab content
                    TabView(selection: $currentTab) {
                        standardPackagesView
                            .tag(0)
                        
                        premiumPackagesView
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                // Empty package overlay
                if viewModel.showEmptyPackageAlert {
                    emptyPackageOverlay
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedPackageForNavigation) { packageId in
                WordSelectionView(packageId: packageId, selectedTab: $selectedTab)
            }
            .sheet(isPresented: $viewModel.showPremiumSheet) {
                PremiumPaywallView()
            }
        }
    }
    
    // MARK: - Back Button Row
    private var backButtonRow: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("back_button")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(currentTab == 0 ? .themePrimaryButton : goldColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
    
    // MARK: - Tab Selector (Full-Width with Animated Slider)
    private var tabSelector: some View {
        ZStack {
            // Background capsule
            RoundedRectangle(cornerRadius: 16)
                .fill(isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04))
            
            // Animated sliding indicator
            GeometryReader { geo in
                let tabWidth = geo.size.width / 2
                
                RoundedRectangle(cornerRadius: 13)
                    .fill(tabSliderGradient)
                    .frame(width: tabWidth - 6, height: geo.size.height - 8)
                    .offset(x: currentTab == 0 ? 4 : tabWidth + 2, y: 4)
                    .shadow(
                        color: currentTab == 0
                            ? Color.themePrimaryButtonShadow.opacity(0.3)
                            : Color(hex: "FFD700").opacity(0.2),
                        radius: 6,
                        y: 2
                    )
            }
            
            // Tab buttons
            HStack(spacing: 0) {
                PackageTabButton(
                    title: "tab_standard",
                    icon: "book.fill",
                    isSelected: currentTab == 0,
                    accentColor: .themePrimaryButton,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentTab = 0
                        }
                    }
                )
                
                PackageTabButton(
                    title: "tab_premium",
                    icon: "crown.fill",
                    isSelected: currentTab == 1,
                    accentColor: goldColor,
                    showBadge: true,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            currentTab = 1
                        }
                    }
                )
            }
        }
        .frame(height: 48)
    }
    
    // MARK: - Standard Packages View
    private var standardPackagesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Compact header
                compactHeader(
                    title: "package_selection_title",
                    info: standardInfoText
                )
                
                // Package grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.standardPackages) { package in
                        StandardPackageCard(
                            package: package,
                            isSelected: viewModel.selectedPackageId == package.id,
                            unseenCount: viewModel.getUnseenWordCount(for: package.id)
                        ) {
                            handlePackageSelection(package)
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Premium Packages View
    private var premiumPackagesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Compact header with upgrade button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("premium_packages_title")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.themePrimary)
                        
                        Text(premiumInfoText)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.themeSecondary)
                    }
                    
                    Spacer()
                    
                    // Compact upgrade button
                    if !viewModel.isPremium {
                        Button(action: { viewModel.showPremiumSheet = true }) {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 11, weight: .bold))
                                Text("premium_upgrade_short")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "FFD700").opacity(0.3), radius: 8, y: 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // Package grid
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.premiumPackages) { package in
                        PremiumPackageCard(
                            package: package,
                            isSelected: viewModel.selectedPackageId == package.id,
                            unseenCount: viewModel.getUnseenWordCount(for: package.id),
                            isPremiumUser: viewModel.isPremium
                        ) {
                            handlePackageSelection(package)
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Compact Header
    private func compactHeader(title: LocalizedStringKey, info: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
            
            Text(info)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.themeSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Info Text Helpers
    private var standardInfoText: String {
        let totalPackages = viewModel.standardPackages.count
        let totalWords = viewModel.standardPackages.reduce(0) { $0 + $1.wordCount }
        return "\(totalPackages) " + NSLocalizedString("packages_count", comment: "") + " · \(totalWords) " + NSLocalizedString("words_count", comment: "")
    }
    
    private var premiumInfoText: String {
        let totalPackages = viewModel.premiumPackages.count
        return "\(totalPackages) " + NSLocalizedString("collections_count", comment: "") + " · " + NSLocalizedString("thematic_content", comment: "")
    }
    
    // MARK: - Empty Package Overlay
    private var emptyPackageOverlay: some View {
        ZStack {
            Color.black.opacity(isDarkMode ? 0.7 : 0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture {
                    withAnimation { viewModel.showEmptyPackageAlert = false }
                }
            
            VStack(spacing: 25) {
                Circle()
                    .fill(LinearGradient(
                        colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    )
                
                VStack(spacing: 12) {
                    Text("package_empty_title")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    Text("package_empty_message")
                        .font(.system(size: 16))
                        .foregroundColor(.themeSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    withAnimation { viewModel.showEmptyPackageAlert = false }
                }) {
                    Text("package_empty_button")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.themePrimaryButton)
                        .cornerRadius(16)
                }
            }
            .padding(30)
            .background(Color.themeCard)
            .cornerRadius(32)
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Helpers
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    
    private var tabSliderGradient: LinearGradient {
        currentTab == 0
            ? LinearGradient(
                colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd],
                startPoint: .leading,
                endPoint: .trailing
            )
            : LinearGradient(
                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                startPoint: .leading,
                endPoint: .trailing
            )
    }
    
    private func handlePackageSelection(_ package: PackageModel) {
        let unseenCount = viewModel.getUnseenWordCount(for: package.id)
        if unseenCount == 0 {
            withAnimation(.spring()) { viewModel.showEmptyPackageAlert = true }
        } else {
            viewModel.selectPackage(package)
            if !package.isPremium || viewModel.isPremium {
                selectedPackageForNavigation = package.id
            }
        }
    }
}

// MARK: - Preview
struct PackageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        PackageSelectionView(selectedTab: .constant(0))
    }
}
