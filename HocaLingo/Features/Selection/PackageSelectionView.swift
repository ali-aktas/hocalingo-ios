//
//  PackageSelectionView.swift
//  HocaLingo
//
//  ✅ CLEAN: Main layout only, components separated
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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Tab Selector
                    tabSelector
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    
                    // Tab Content
                    TabView(selection: $currentTab) {
                        standardPackagesView
                            .tag(0)
                        
                        premiumPackagesView
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                if viewModel.showEmptyPackageAlert {
                    emptyPackageOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedPackageForNavigation) { packageId in
                WordSelectionView(packageId: packageId, selectedTab: $selectedTab)
            }
            .sheet(isPresented: $viewModel.showPremiumSheet) {
                PremiumPaywallView()
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            // Standard Tab
            PackageTabButton(
                title: "tab_standard",
                icon: "book.fill",
                isSelected: currentTab == 0,
                accentColor: .themePrimaryButton,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentTab = 0
                    }
                }
            )
            
            // Premium Tab
            PackageTabButton(
                title: "tab_premium",
                icon: "crown.fill",
                isSelected: currentTab == 1,
                accentColor: Color(hex: "FFD700"),
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentTab = 1
                    }
                }
            )
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isDarkMode ? Color.white.opacity(0.1) : Color.gray.opacity(0.15))
        )
    }
    
    // MARK: - Standard Packages View
    private var standardPackagesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection(
                    title: "package_selection_title",
                    subtitle: "package_selection_subtitle"
                )
                
                LazyVGrid(columns: columns, spacing: 16) {
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
                .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }
    
    // MARK: - Premium Packages View
    private var premiumPackagesView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                premiumHeaderSection
                
                LazyVGrid(columns: columns, spacing: 16) {
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
                .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }
    
    // MARK: - Premium Header
    private var premiumHeaderSection: some View {
        VStack(spacing: 16) {
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
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
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
                    .frame(width: 70, height: 70)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("premium_header_title")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.themePrimary)
                
                Text("premium_header_subtitle")
                    .font(.system(size: 15))
                    .foregroundColor(.themeSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if !viewModel.isPremium {
                Button(action: { viewModel.showPremiumSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("premium_upgrade_button")
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
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
                    .cornerRadius(20)
                    .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 12, y: 6)
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Header Section
    private func headerSection(title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.themePrimary)
            
            Text(subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 5)
    }
    
    // MARK: - Empty Package Overlay
    private var emptyPackageOverlay: some View {
        ZStack {
            Color.black.opacity(isDarkMode ? 0.7 : 0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture { withAnimation { viewModel.showEmptyPackageAlert = false } }
            
            VStack(spacing: 25) {
                Circle()
                    .fill(LinearGradient(colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: "checkmark.seal.fill").foregroundColor(.white).font(.title))
                
                VStack(spacing: 12) {
                    Text("package_empty_title")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    Text("package_empty_message")
                        .font(.system(size: 16))
                        .foregroundColor(.themeSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: { withAnimation { viewModel.showEmptyPackageAlert = false } }) {
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
