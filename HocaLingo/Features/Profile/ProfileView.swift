//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ UPDATED: Direction picker now functional
//  Location: HocaLingo/Features/Profile/ProfileView.swift
//

import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showPremiumSheet = false
    @State private var showDirectionPicker = false  // ✅ NEW
    @State private var showThemePicker = false      // ✅ NEW (for future)
    @State private var showGoalPicker = false       // ✅ NEW (for future)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    ProfileHeader()
                    
                    // Premium Card
                    PremiumCard(
                        isPremium: viewModel.isPremium,
                        onUpgradeClick: {
                            showPremiumSheet = true
                        }
                    )
                    
                    // Stats Row
                    StatsRow(stats: viewModel.userStats)
                    
                    // Settings Card
                    SettingsCard(
                        themeMode: viewModel.themeMode,
                        notificationsEnabled: $viewModel.notificationsEnabled,
                        studyDirection: viewModel.studyDirection,
                        dailyGoal: viewModel.dailyGoal,
                        onThemeClick: {
                            showThemePicker = true  // TODO: Implement later
                        },
                        onDirectionClick: {
                            showDirectionPicker = true  // ✅ NEW
                        },
                        onGoalClick: {
                            showGoalPicker = true  // TODO: Implement later
                        },
                        onNotificationToggle: {
                            viewModel.toggleNotifications()
                        }
                    )
                    
                    // Legal & Support
                    LegalAndSupportCard()
                    
                    // Bottom spacer
                    Color.clear.frame(height: 80)
                }
                .padding(16)
            }
            .background(Color(hex: "F5F5F5"))
            .navigationTitle("profile_tab")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumSheetPlaceholder()
        }
        // ✅ NEW: Direction Picker ActionSheet
        .confirmationDialog(
            "Çalışma Yönü Seçin",
            isPresented: $showDirectionPicker,
            titleVisibility: .visible
        ) {
            ForEach(StudyDirection.allCases, id: \.self) { direction in
                Button(direction.displayName) {
                    viewModel.changeStudyDirection(to: direction)
                }
            }
            
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Yeni yön seçtiğinizde, her kelime için ayrı ilerleme takibi olacaktır.")
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                )
            
            Text("HocaLingo Kullanıcısı")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Başarılı bir öğrenme yolculuğu!")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Premium Card
struct PremiumCard: View {
    let isPremium: Bool
    let onUpgradeClick: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "FFD700"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPremium ? "Premium Üye" : "Premium'a Geç")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(isPremium ? "Sınırsız özelliklerin keyfini çıkarın" : "Tüm özellikleri aç")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !isPremium {
                Button(action: onUpgradeClick) {
                    Text("Yükselt")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(
            isPremium ?
            LinearGradient(
                colors: [Color(hex: "FFD700").opacity(0.1), Color(hex: "FFA500").opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            ) :
            LinearGradient(
                colors: [Color.white, Color.white],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPremium ? Color(hex: "FFD700") : Color.clear, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Stats Row
struct StatsRow: View {
    let stats: UserStats
    
    var body: some View {
        HStack(spacing: 12) {
            StatItem(
                icon: "checkmark.circle.fill",
                value: "\(stats.totalWordsStudied)",
                label: "Çalışılan",
                color: Color(hex: "4ECDC4")
            )
            
            StatItem(
                icon: "star.fill",
                value: "\(stats.masteredWordsCount)",
                label: "Öğrenilen",
                color: Color(hex: "FFD93D")
            )
            
            StatItem(
                icon: "flame.fill",
                value: "\(stats.currentStreak)",
                label: "Seri",
                color: Color(hex: "FF6B6B")
            )
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Settings Card
/// ✅ UPDATED: Added action callbacks for each setting
struct SettingsCard: View {
    let themeMode: ThemeMode
    @Binding var notificationsEnabled: Bool
    let studyDirection: StudyDirection
    let dailyGoal: Int
    let onThemeClick: () -> Void
    let onDirectionClick: () -> Void  // ✅ NEW
    let onGoalClick: () -> Void
    let onNotificationToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("settings_title")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Theme Setting
            SettingRow(
                icon: "moon.fill",
                title: "settings_theme",
                subtitle: themeMode.displayName
            ) {
                onThemeClick()
            }
            
            Divider()
            
            // Notifications Toggle
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 32)
                    
                    Text("settings_notifications")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .onChange(of: notificationsEnabled) { _ in
                        onNotificationToggle()
                    }
            }
            .padding(16)
            
            Divider()
            
            // ✅ UPDATED: Study Direction with action
            SettingRow(
                icon: "arrow.left.arrow.right",
                title: "settings_direction",
                subtitle: studyDirection.displayName
            ) {
                onDirectionClick()  // ✅ Calls the action
            }
            
            Divider()
            
            // Daily Goal
            SettingRow(
                icon: "target",
                title: "settings_daily_goal",
                subtitle: "\(dailyGoal) words"
            ) {
                onGoalClick()
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Legal & Support Card
struct LegalAndSupportCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("legal_support")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Privacy Policy
            LegalRow(icon: "lock.shield.fill", title: "privacy_policy") {
                // TODO: Open privacy policy
            }
            
            Divider()
            
            // Terms of Service
            LegalRow(icon: "doc.text.fill", title: "terms_of_service") {
                // TODO: Open terms
            }
            
            Divider()
            
            // Contact Support
            LegalRow(icon: "envelope.fill", title: "contact_support") {
                // TODO: Open support
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Legal Row
struct LegalRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
    }
}
