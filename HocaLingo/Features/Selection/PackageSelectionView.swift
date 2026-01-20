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
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                // Arka plan dekorasyonu
                VStack {
                    Circle()
                        .fill(Color.themePrimaryButton.opacity(0.08))
                        .frame(width: 400, height: 400)
                        .blur(radius: 70)
                        .offset(x: 150, y: -200)
                    Spacer()
                }
                
                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.2).tint(.themePrimaryButton)
                        Text(NSLocalizedString("loading", comment: ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.themeSecondary)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            headerSection
                            
                            LazyVGrid(columns: columns, spacing: 20) {
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
                        .padding(.top, 10)
                        .padding(.bottom, 100)
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
    
    private func handlePackageSelection(_ package: PackageModel) {
        let unseenCount = viewModel.getUnseenWordCount(for: package.id)
        if unseenCount == 0 {
            viewModel.showEmptyPackageAlert = true
        } else {
            viewModel.selectPackage(package.id)
            selectedPackageForNavigation = package.id
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(NSLocalizedString("package_selection_title", comment: ""))
                .font(.system(size: 34, weight: .black))
                .tracking(-1)
                .foregroundColor(.themePrimary)
            
            Text(NSLocalizedString("package_selection_subtitle", comment: ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 10)
    }
    
    private var emptyPackageOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture { viewModel.showEmptyPackageAlert = false }
            
            VStack(spacing: 25) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    Image(systemName: "star.fill")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: .themePrimaryButtonShadow, radius: 15, x: 0, y: 8)
                
                VStack(spacing: 12) {
                    Text(NSLocalizedString("package_empty_title", comment: ""))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.themePrimary)
                    
                    Text(NSLocalizedString("package_empty_message", comment: ""))
                        .font(.system(size: 16))
                        .foregroundColor(.themeSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                Button(action: { viewModel.showEmptyPackageAlert = false }) {
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(package.level)
                        .font(.system(size: 12, weight: .black))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(.white.opacity(isDarkMode ? 0.2 : 0.9))
                        .foregroundColor(isDarkMode ? .white : Color(hex: package.colorHex))
                        .clipShape(Capsule())
                    Spacer()
                    Image(systemName: unseenCount == 0 ? "checkmark.seal.fill" : "chevron.right.circle.fill")
                        .font(.system(size: 18)).foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name).font(.system(size: 18, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    Text(unseenCount == 0
                         ? NSLocalizedString("package_completed", comment: "")
                         : "\(unseenCount) " + NSLocalizedString("package_words_left", comment: ""))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16).frame(height: 150).frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Color(hex: package.colorHex), Color(hex: package.colorHex).opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(systemName: "square.stack.3d.up.fill").font(.system(size: 60)).offset(x: 10, y: 10).opacity(0.12).foregroundColor(.white)
                }
            )
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(isSelected ? Color.themePrimaryButton : Color.clear, lineWidth: 3))
            .shadow(color: Color(hex: package.colorHex).opacity(0.3), radius: 8, x: 0, y: 6)
            .scaleEffect(isSelected ? 0.96 : 1.0)
            .opacity(unseenCount == 0 ? 0.75 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}
