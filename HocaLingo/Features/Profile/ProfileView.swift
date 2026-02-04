//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ FIXED: Premium badge only shows paywall for free users
//  ✅ FIXED: Removed duplicate SettingsCard, using existing component correctly
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
            // ✅ FIX: Only show paywall if user is NOT premium
            if !viewModel.isPremium {
                showPremiumSheet = true
            }
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
                    Text(viewModel.isPremium ? "premium_card_title" : "premium_card_upgrade_button")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    Text(viewModel.isPremium ? "premium_active_description" : "premium_card_subtitle")
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                }
                
                Spacer()
                
                // Arrow icon (only for free users)
                if !viewModel.isPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeSecondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
                    .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 4)
            )
        }
        // ✅ FIX: Disable button for premium users
        .disabled(viewModel.isPremium)
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
            
            // 1. Notifications Toggle
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
        }
    }
}

// MARK: - Safari View (In-App Browser)
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
