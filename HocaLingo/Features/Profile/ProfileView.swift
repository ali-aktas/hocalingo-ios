import SwiftUI

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showPremiumSheet = false
    
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
                        themeMode: $viewModel.themeMode,
                        notificationsEnabled: $viewModel.notificationsEnabled,
                        studyDirection: $viewModel.studyDirection,
                        dailyGoal: $viewModel.dailyGoal
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
            
            // Welcome text
            Text("profile_welcome")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Premium Card
struct PremiumCard: View {
    let isPremium: Bool
    let onUpgradeClick: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if isPremium {
                // Premium Badge
                HStack(spacing: 8) {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                    Text("premium_active")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
            } else {
                // Upgrade Button
                Button(action: onUpgradeClick) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("premium_upgrade_title")
                                .font(.system(size: 16, weight: .semibold))
                            Text("premium_upgrade_subtitle")
                                .font(.system(size: 12))
                                .opacity(0.8)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                    }
                    .padding(16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Stats Row
struct StatsRow: View {
    let stats: UserStats
    
    var body: some View {
        HStack(spacing: 12) {
            StatItem(
                icon: "flame.fill",
                value: "\(stats.currentStreak)",
                label: "stats_streak",
                color: Color(hex: "F59E0B")
            )
            
            StatItem(
                icon: "book.fill",
                value: "\(stats.totalWordsSelected)",
                label: "stats_words",
                color: Color(hex: "6366F1")
            )
            
            StatItem(
                icon: "checkmark.circle.fill",
                value: "\(stats.masteredWordsCount)",
                label: "stats_mastered",
                color: Color(hex: "10B981")
            )
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let value: String
    let label: LocalizedStringKey
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
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    @Binding var themeMode: ThemeMode
    @Binding var notificationsEnabled: Bool
    @Binding var studyDirection: StudyDirection
    @Binding var dailyGoal: Int
    
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
                // TODO: Show theme picker
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
            }
            .padding(16)
            
            Divider()
            
            // Study Direction
            SettingRow(
                icon: "arrow.left.arrow.right",
                title: "settings_direction",
                subtitle: studyDirection.displayName
            ) {
                // TODO: Show direction picker
            }
            
            Divider()
            
            // Daily Goal
            SettingRow(
                icon: "target",
                title: "settings_daily_goal",
                subtitle: "\(dailyGoal) words"
            ) {
                // TODO: Show goal picker
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
    let title: LocalizedStringKey
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
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
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
    }
}

// MARK: - Legal & Support Card
struct LegalAndSupportCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("legal_title")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Privacy Policy
            LegalRow(
                icon: "lock.shield.fill",
                title: "legal_privacy",
                action: {
                    openURL("https://sites.google.com/view/hocalingoprivacypolicy/ana-sayfa")
                }
            )
            
            Divider()
            
            // Terms of Service
            LegalRow(
                icon: "doc.text.fill",
                title: "legal_terms",
                action: {
                    openURL("https://sites.google.com/view/hocalingo-kullanicisozlesmesi/ana-sayfa")
                }
            )
            
            Divider()
            
            // App Store
            LegalRow(
                icon: "star.fill",
                title: "legal_rate_app",
                action: {
                    // TODO: Open App Store rating
                }
            )
            
            Divider()
            
            // Support
            LegalRow(
                icon: "envelope.fill",
                title: "legal_support",
                action: {
                    openURL("mailto:aliaktasofficial@gmail.com")
                }
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Legal Row
struct LegalRow: View {
    let icon: String
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 32)
                    
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
    }
}

// MARK: - Premium Sheet Placeholder
struct PremiumSheetPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Premium Coming Soon!")
                    .font(.system(size: 24, weight: .bold))
                
                Text("RevenueCat integration in Phase 4")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
}
