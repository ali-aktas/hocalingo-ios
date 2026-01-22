//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Modern, clean UI with generic SettingsCard component
//  All settings use the same reusable card - easy to maintain & extend
//  Location: Features/Profile/ProfileView.swift
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showPremiumSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Premium Card
                    premiumCard
                    
                    // Annual Statistics Section
                    AnnualStatsSection(annualStats: viewModel.annualStats)
                    
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
            PremiumSheetPlaceholder()
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
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.themePrimary)
                    
                    Text(viewModel.isPremium ? "Unlimited access" : "premium_card_subtitle")
                        .font(.system(size: 13))
                        .foregroundColor(.themeSecondary)
                }
                
                Spacer()
                
                // Upgrade Button or Checkmark
                if viewModel.isPremium {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentGreen)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(16)
            .background(
                ZStack {
                    Color.themeCard
                    
                    // Gradient overlay for non-premium
                    if !viewModel.isPremium {
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700").opacity(0.1),
                                Color(hex: "FFA500").opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700").opacity(0.5),
                                Color(hex: "FFA500").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color(hex: "FFD700").opacity(0.2), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Settings Section (GÜNCELLENDİ: Sıralama Değişti)
    private var settingsSection: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("settings_title")
                    .font(.system(size: 18, weight: .semibold))
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
                    .font(.system(size: 18, weight: .semibold))
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
                            // GÜNCELLENDİ: Gizlilik Politikasını Aç
                            if let url = URL(string: "https://www.seninsiten.com/privacy") {
                                UIApplication.shared.open(url)
                            }
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
                            // GÜNCELLENDİ: Kullanım Şartlarını Aç
                            if let url = URL(string: "https://www.seninsiten.com/terms") {
                                UIApplication.shared.open(url)
                            }
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
                            // GÜNCELLENDİ: Mail Uygulamasını Aç
                            let email = "support@hocalingo.com"
                            if let url = URL(string: "mailto:\(email)") {
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
    
    // MARK: - Premium Sheet Placeholder
    struct PremiumSheetPlaceholder: View {
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "FFD700").opacity(0.2),
                        Color(hex: "FFA500").opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Crown Icon
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
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Text("Premium")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.themePrimary)
                    
                    Text("Coming soon...")
                        .font(.system(size: 18))
                        .foregroundColor(.themeSecondary)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold))
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
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
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
}
