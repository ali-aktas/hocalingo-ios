//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ UPDATED: GitHub Pages URLs + In-App Safari + Real Support Email
//  Location: Features/Profile/ProfileView.swift
//

import SwiftUI
import SafariServices

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPremiumSheet = false
    
    // ✅ NEW: Safari sheet states for in-app browser
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Premium Card
                    premiumCard
                    
                    // Annual Statistics Section
                    //AnnualStatsSection(annualStats: viewModel.annualStats)
                    
                    // Settings Section
                    settingsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.themeBackground)
            .navigationTitle("profile_welcome")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumPaywallView()
        }
        // ✅ NEW: In-App Safari sheets
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/privacy-policy.html")!)
        }
        .sheet(isPresented: $showTermsOfService) {
            SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/terms-of-service.html")!)
        }
    }
    
    // MARK: - Premium Card
    private var premiumCard: some View {
        Button(action: {
            showPremiumSheet = true
        }) {
            HStack(spacing: 16) {
                // Premium Icon
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
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: viewModel.isPremium ? "crown.fill" : "star.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                // Premium Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isPremium ? "premium_active" : "premium_card_title")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    Text(viewModel.isPremium ? "premium_card_subtitle" : "premium_upgrade_subtitle")
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                }
                
                Spacer()
                
                // Chevron or Crown
                if !viewModel.isPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: viewModel.isPremium
                        ? [Color(hex: "FFD700").opacity(0.2), Color(hex: "FFA500").opacity(0.1)]
                        : [Color.themeCard, Color.themeCard],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        viewModel.isPremium
                            ? LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: viewModel.isPremium ? 2 : 0
                    )
            )
            .shadow(color: viewModel.isPremium ? Color(hex: "FFD700").opacity(0.3) : Color.themeShadow, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack {
                Text("settings_title")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.themePrimary)
                Spacer()
            }
            
            // 1. Notifications Toggle (Premium'dan hemen sonra)
            SettingsCard(
                type: .notificationToggle(
                    isOn: $viewModel.notificationsEnabled,
                    selectedHour: $viewModel.notificationTime,
                    onToggle: {
                        viewModel.toggleNotifications()
                    },
                    onTimeChange: { hour in
                        viewModel.changeNotificationTime(to: hour)
                    }
                )
            )
            
            // 2. Study Direction Selection
            SettingsCard(
                type: .studyDirectionSelection(
                    selectedDirection: $viewModel.studyDirection,
                    onDirectionChange: { direction in
                        viewModel.changeStudyDirection(to: direction)
                    }
                )
            )
            
            // 3. Theme Selection
            SettingsCard(
                type: .themeSelection(
                    selectedTheme: $viewModel.themeMode,
                    onThemeChange: { theme in
                        viewModel.changeThemeMode(to: theme)
                        themeViewModel.updateTheme(to: theme)
                    }
                )
            )
            
            // 4. Language Selection
            SettingsCard(
                type: .languageSelection(
                    selectedLanguage: $viewModel.appLanguage,
                    onLanguageChange: { language in
                        viewModel.changeLanguage(to: language)
                    }
                )
            )
            
            // Legal & Support Section
            legalSupportSection
        }
    }
    
    // MARK: - Legal & Support Section
    private var legalSupportSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("legal_title")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.themePrimary)
                Spacer()
            }
            
            VStack(spacing: 0) {
                // Privacy Policy
                SettingsCard(
                    type: .action(
                        icon: "lock.shield.fill",
                        iconColor: .accentPurple,
                        title: "legal_privacy",
                        subtitle: nil,
                        showChevron: true,
                        action: {
                            // ✅ UPDATED: Open in-app Safari
                            showPrivacyPolicy = true
                        }
                    )
                )
                
                Divider()
                    .background(Color.themeDivider)
                
                // Terms of Service
                SettingsCard(
                    type: .action(
                        icon: "doc.text.fill",
                        iconColor: .accentOrange,
                        title: "legal_terms",
                        subtitle: nil,
                        showChevron: true,
                        action: {
                            // ✅ UPDATED: Open in-app Safari
                            showTermsOfService = true
                        }
                    )
                )
                
                Divider()
                    .background(Color.themeDivider)
                
                // Contact Support
                SettingsCard(
                    type: .action(
                        icon: "envelope.fill",
                        iconColor: .accentGreen,
                        title: "legal_support",
                        subtitle: "legal_support_subtitle",
                        showChevron: true,
                        action: {
                            // ✅ UPDATED: Real support email
                            let email = "auraliastudios@gmail.com"
                            let subject = "HocaLingo iOS - Support Request"
                            let body = "Hello HocaLingo team,\n\n"
                            
                            let mailtoString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                            
                            if let url = URL(string: mailtoString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    )
                )
            }
            .background(Color.themeCard)
            .cornerRadius(16)
            .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Safari View Wrapper
/// SwiftUI wrapper for SFSafariViewController (in-app browser)
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false // Don't auto-enter reader mode
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredBarTintColor = UIColor.systemBackground
        safari.preferredControlTintColor = UIColor(Color.themePrimary)
        
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProfileView()
                .environment(\.themeViewModel, ThemeViewModel.shared)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Theme")
            
            ProfileView()
                .environment(\.themeViewModel, ThemeViewModel.shared)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Theme")
        }
    }
}
