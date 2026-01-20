//
//  PackageSelectionView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIXES:
//  - Empty package detection (all words seen → show message + back button)
//  - Language change support (AppLanguageChanged notification)
//  - Full localization (EN/TR)
//  - navigationDestination instead of fullScreenCover (MainTabView visible!)
//
//  Location: HocaLingo/Features/Selection/PackageSelectionView.swift
//

import SwiftUI

// MARK: - Package Selection View
struct PackageSelectionView: View {
    @StateObject private var viewModel = PackageSelectionViewModel()
    @State private var selectedPackageForNavigation: String? = nil
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    // ✅ NEW: Track language changes
    @State private var refreshTrigger = UUID()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Theme-aware background
                backgroundColor
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Header
                            headerSection
                            
                            // Package Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.packages) { package in
                                    PackageCard(
                                        package: package,
                                        isSelected: viewModel.selectedPackageId == package.id,
                                        unseenCount: viewModel.getUnseenWordCount(for: package.id)
                                    ) {
                                        // ✅ CRITICAL: Check if package is empty
                                        let unseenCount = viewModel.getUnseenWordCount(for: package.id)
                                        if unseenCount == 0 {
                                            // Show empty message
                                            viewModel.showEmptyPackageAlert = true
                                        } else {
                                            viewModel.selectPackage(package.id)
                                            selectedPackageForNavigation = package.id
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 50) // Space for bottom nav
                    }
                }
                
                // ✅ NEW: Empty package alert overlay
                if viewModel.showEmptyPackageAlert {
                    emptyPackageOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            // ✅ CRITICAL FIX: Use navigationDestination instead of fullScreenCover!
            .navigationDestination(item: $selectedPackageForNavigation) { packageId in
                WordSelectionView(packageId: packageId)
            }
            // ✅ NEW: Listen for language changes
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppLanguageChanged"))) { _ in
                refreshTrigger = UUID()
            }
            .id(refreshTrigger) // Force view refresh on language change
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(NSLocalizedString("package_selection_title", comment: ""))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(NSLocalizedString("package_selection_subtitle", comment: ""))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    // ✅ NEW: Empty package alert overlay
    private var emptyPackageOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.showEmptyPackageAlert = false
                }
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: "10B981").opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Message
                VStack(spacing: 12) {
                    Text(NSLocalizedString("package_empty_title", comment: ""))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(NSLocalizedString("package_empty_message", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                // Close button
                Button(action: {
                    viewModel.showEmptyPackageAlert = false
                }) {
                    Text(NSLocalizedString("package_empty_button", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(14)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Theme Colors
    
    private var backgroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "121212")
            : Color(hex: "F5F5F5")
    }
}

// MARK: - Package Card
struct PackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let unseenCount: Int
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                
                // Top section
                VStack(alignment: .leading, spacing: 8) {
                    // Level badge
                    Text(package.level)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(isDarkMode ? Color.black : Color(hex: package.colorHex))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(levelBadgeBackground)
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    // Package name
                    Text(package.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    // Description
                    Text(package.description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // ✅ NEW: Unseen count or completion badge
                    if unseenCount == 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text(NSLocalizedString("package_completed", comment: ""))
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.top, 4)
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 12))
                            Text("\(unseenCount) \(NSLocalizedString("package_words_left", comment: ""))")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.top, 4)
                    }
                }
            }
            .padding(18)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: cardGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? themeAccentColor : Color.clear, lineWidth: 3)
            )
            .shadow(
                color: .black.opacity(isDarkMode ? 0.3 : 0.15),
                radius: isSelected ? 12 : 8,
                x: 0,
                y: isSelected ? 6 : 4
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
            // ✅ Dim completed packages
            .opacity(unseenCount == 0 ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Theme Colors
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
    
    private var levelBadgeBackground: Color {
        isDarkMode
            ? Color.white.opacity(0.2)
            : Color.white.opacity(0.95)
    }
    
    private var cardGradientColors: [Color] {
        let baseColor = Color(hex: package.colorHex)
        
        if isDarkMode {
            // Darker gradient for dark mode
            return [
                baseColor.opacity(0.8),
                baseColor.opacity(0.6)
            ]
        } else {
            // Lighter gradient for light mode
            return [
                baseColor,
                baseColor.opacity(0.85)
            ]
        }
    }
    
    private var themeAccentColor: Color {
        Color(hex: "4ECDC4")
    }
}

// MARK: - Navigation Item (for navigationDestination)
extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Preview
#Preview {
    PackageSelectionView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
