//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN: Modern profile screen with language selection, annual stats, and improved UI
//  ✅ FIX: ThemeViewModel now properly using environment injection
//  Location: HocaLingo/Features/Profile/ProfileView.swift
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.themeViewModel) private var themeViewModel  // ✅ FIX: Use environment instead of @StateObject
    @State private var showPremiumSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Premium Card
                    PremiumCard(
                        isPremium: viewModel.isPremium,
                        onUpgradeClick: {
                            showPremiumSheet = true
                        }
                    )
                    
                    // Annual Statistics Section (NEW)
                    AnnualStatsSection(annualStats: viewModel.annualStats)
                    
                    // Language Selection Card (NEW)
                    LanguageSelectionCard(
                        selectedLanguage: $viewModel.appLanguage,
                        onLanguageChange: { language in
                            viewModel.changeLanguage(to: language)
                        }
                    )
                    
                    // Study Direction Card (NEW - Distinct Design)
                    StudyDirectionCard(
                        selectedDirection: $viewModel.studyDirection,
                        onDirectionChange: { direction in
                            viewModel.changeStudyDirection(to: direction)
                        }
                    )
                    
                    // Notification Card (NEW - Professional)
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
                            themeViewModel.updateTheme(to: theme)  // ✅ FIX: Correct method name
                        }
                    )
                    
                    // Legal & Support Section (UPDATED - Working Links)
                    LegalSupportSection()
                    
                    // Bottom Padding
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(hex: "F8F9FA").ignoresSafeArea())
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

// MARK: - Premium Card
struct PremiumCard: View {
    let isPremium: Bool
    let onUpgradeClick: () -> Void
    
    var body: some View {
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
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(isPremium ? "premium_active" : "premium_upgrade_title")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(isPremium ? "Sınırsız Erişim" : "premium_upgrade_subtitle")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action Button (only for non-premium)
            if !isPremium {
                Button(action: onUpgradeClick) {
                    HStack(spacing: 6) {
                        Text("Geç")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "6366F1"),
                                Color(hex: "8B5CF6")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 32)
                    
                    Text("settings_theme")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
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
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
                    .foregroundColor(isSelected ? Color(hex: "6366F1") : .gray)
                    .frame(width: 32)
                
                Text(theme.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray.opacity(0.3))
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
        ProfileView()
            .environment(\.themeViewModel, ThemeViewModel.shared)
    }
}
