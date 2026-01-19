//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ MAJOR UPDATE: Full dark theme support, clickable premium card, professional UI
//  Location: HocaLingo/Features/Profile/ProfileView.swift
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
            ScrollView {
                VStack(spacing: 20) {
                    // Premium Card (UPDATED - Fully clickable)
                    PremiumCard(
                        isPremium: viewModel.isPremium,
                        onUpgradeClick: {
                            showPremiumSheet = true
                        }
                    )
                    
                    // Annual Statistics Section (UPDATED - Compact 3 cards)
                    AnnualStatsSection(annualStats: viewModel.annualStats)
                    
                    // Language Selection Card
                    LanguageSelectionCard(
                        selectedLanguage: $viewModel.appLanguage,
                        onLanguageChange: { language in
                            viewModel.changeLanguage(to: language)
                        }
                    )
                    
                    // Study Direction Card (NO MORE MIXED)
                    StudyDirectionCard(
                        selectedDirection: $viewModel.studyDirection,
                        onDirectionChange: { direction in
                            viewModel.changeStudyDirection(to: direction)
                        }
                    )
                    
                    // Notification Card
                    NotificationCard(
                        isEnabled: $viewModel.notificationsEnabled,
                        notificationHour: $viewModel.notificationTime,
                        onToggle: {
                            viewModel.toggleNotifications()
                        },
                        onTimeChange: { hour in
                            viewModel.changeNotificationTime(to: hour)
                        }
                    )
                    
                    // Theme Selection Card
                    ThemeSelectionCard(
                        selectedTheme: $viewModel.themeMode,
                        onThemeChange: { theme in
                            viewModel.changeThemeMode(to: theme)
                            themeViewModel.updateTheme(to: theme)
                        }
                    )
                    
                    // Legal & Support Section
                    LegalSupportSection()
                    
                    // Bottom Padding
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationTitle("profile_welcome")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPremiumSheet) {
                PremiumSheetPlaceholder()
            }
            .onAppear {
                // Refresh stats when view appears
                viewModel.refreshAnnualStats()
            }
        }
    }
}

// MARK: - Premium Card (UPDATED - Fully Clickable)
struct PremiumCard: View {
    let isPremium: Bool
    let onUpgradeClick: () -> Void
    
    var body: some View {
        Button(action: {
            if !isPremium {
                onUpgradeClick()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isPremium ? [
                                    Color(hex: "F59E0B"),
                                    Color(hex: "EF4444")
                                ] : [
                                    Color(hex: "6366F1"),
                                    Color(hex: "8B5CF6")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: isPremium ? "crown.fill" : "star.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                
                // Text Content (UPDATED - Proper sizing)
                VStack(alignment: .leading, spacing: 6) {
                    Text(isPremium ? "premium_active" : "premium_upgrade_title")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.themePrimary)
                        .lineLimit(1)
                    
                    Text(isPremium ? "Sınırsız Erişim" : "premium_upgrade_subtitle")
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Chevron indicator (only for non-premium)
                if !isPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeSecondary)
                }
            }
            .padding(20)
            .background(Color.themeCard)
            .cornerRadius(16)
            .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Theme Selection Card
struct ThemeSelectionCard: View {
    @Binding var selectedTheme: ThemeMode
    let onThemeChange: (ThemeMode) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                        .frame(width: 32)
                    
                    Text("settings_theme")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themePrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.themeDivider)
            
            // Theme Options
            ForEach([ThemeMode.system, ThemeMode.light, ThemeMode.dark], id: \.self) { theme in
                ThemeOptionRow(
                    theme: theme,
                    isSelected: selectedTheme == theme,
                    onSelect: {
                        selectedTheme = theme
                        onThemeChange(theme)
                    }
                )
                
                if theme != ThemeMode.dark {
                    Divider()
                        .padding(.leading, 60)
                        .background(Color.themeDivider)
                }
            }
        }
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Theme Option Row
struct ThemeOptionRow: View {
    let theme: ThemeMode
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: themeIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentPurple : .themeSecondary)
                    .frame(width: 32)
                
                Text(theme.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themeIcon: String {
        switch theme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }
}

// MARK: - Premium Sheet Placeholder
struct PremiumSheetPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Coming soon...")
                .foregroundColor(.secondary)
            
            Button("Close") {
                dismiss()
            }
            .padding()
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
