//
//  PackageSelectionView.swift
//  HocaLingo
//
//  ✅ UPDATED: Theme-aware colors, cleaner design (Android parity)
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
                                        viewModel.selectPackage(package.id)
                                        selectedPackageForNavigation = package.id
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 50) // Space for bottom nav
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
        }
        .fullScreenCover(item: Binding(
            get: { selectedPackageForNavigation.map { PackageNavigationItem(id: $0) } },
            set: { selectedPackageForNavigation = $0?.id }
        )) { item in
            WordSelectionView(packageId: item.id)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Choose Your Level")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Select a package to start learning words")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Theme Colors
    
    private var backgroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "121212")
            : Color(hex: "F5F5F5")
    }
}

// MARK: - Package Card Component
struct PackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let unseenCount: Int
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Level Badge
                HStack {
                    Text(package.level)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(levelBadgeBackground)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    // New words badge (if any)
                    if unseenCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text("\(unseenCount)")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // Title & Description
                VStack(alignment: .leading, spacing: 6) {
                    Text(package.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(package.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Word count
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 12))
                        Text("\(package.wordCount) words")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.95))
                    .padding(.top, 4)
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

// MARK: - Navigation Item
struct PackageNavigationItem: Identifiable {
    let id: String
}

// MARK: - Preview
#Preview {
    PackageSelectionView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
