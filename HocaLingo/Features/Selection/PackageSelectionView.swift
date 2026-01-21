import SwiftUI

// MARK: - Package Selection View
struct PackageSelectionView: View {
    @StateObject private var viewModel = PackageSelectionViewModel()
    @State private var selectedPackageForNavigation: String? = nil
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var refreshTrigger = UUID()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                // MARK: Background Decor (Adaptive Opacity)
                Group {
                    Circle()
                        .fill(Color.themePrimaryButton.opacity(isDarkMode ? 0.12 : 0.05))
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .offset(x: 120, y: -250)
                }
                
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView().tint(.themePrimaryButton)
                        Text(NSLocalizedString("loading", comment: ""))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themeSecondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) { // Spacing slightly reduced
                            headerSection
                            
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.packages) { package in
                                    PackageCard(
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
                        .padding(.top, 0) // Reduced top padding for better spacing with Back button
                        .padding(.bottom, 120)
                    }
                }
                
                if viewModel.showEmptyPackageAlert {
                    emptyPackageOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedPackageForNavigation) { packageId in
                WordSelectionView(packageId: packageId)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("AppLanguageChanged"))) { _ in
                refreshTrigger = UUID()
            }
            .id(refreshTrigger)
        }
    }
    
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }

    private func handlePackageSelection(_ package: PackageModel) {
        let unseenCount = viewModel.getUnseenWordCount(for: package.id)
        if unseenCount == 0 {
            withAnimation(.spring()) { viewModel.showEmptyPackageAlert = true }
        } else {
            viewModel.selectPackage(package.id)
            selectedPackageForNavigation = package.id
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString("package_selection_title", comment: ""))
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.themePrimary) // Adaptive color (Black in light, White in dark)
            
            Text(NSLocalizedString("package_selection_subtitle", comment: ""))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 5) // Minimal padding to reduce gap from navigation area
    }

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
                    Text(NSLocalizedString("package_empty_title", comment: ""))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.themePrimary)
                    
                    Text(NSLocalizedString("package_empty_message", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.themeSecondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: { withAnimation { viewModel.showEmptyPackageAlert = false } }) {
                    Text(NSLocalizedString("package_empty_button", comment: ""))
                        .font(.system(size: 17, weight: .bold))
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
}

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
                HStack {
                    // ✅ Level Localization Fix
                    Text(NSLocalizedString(package.level, comment: ""))
                        .font(.system(size: 14, weight: .heavy))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                        .foregroundColor(isDarkMode ? .white : .primary)
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: unseenCount == 0 ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : .primary.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    // ✅ Title (Name) Localization Fix
                    Text(NSLocalizedString(package.name, comment: ""))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : .primary)
                    
                    Text(unseenCount == 0
                         ? NSLocalizedString("package_completed", comment: "")
                         : "\(unseenCount) " + NSLocalizedString("package_words_left", comment: ""))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isDarkMode ? .white.opacity(0.7) : .primary.opacity(0.6))
                }
            }
            .padding(16)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(isDarkMode
                              ? LinearGradient(colors: [Color(hex: package.colorHex), Color(hex: package.colorHex).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                              : LinearGradient(colors: [Color(hex: package.colorHex).opacity(0.2), Color(hex: package.colorHex).opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(isSelected ? Color.themePrimaryButton : Color.clear, lineWidth: 3))
            .scaleEffect(isSelected ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}
