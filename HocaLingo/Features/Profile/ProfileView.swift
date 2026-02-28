//
//  ProfileView.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Compact layout, premium badge in nav bar, confirmation dialogs
//  ✅ PRESERVED: All functions, colors, localization, theme/dark-mode sensitivity
//  ✅ PRESERVED: Notifications toggle with time picker (SettingsCard)
//  ✅ REPLACED: Expandable inlineSelection cards → CompactSelectorRow
//  ✅ MOVED: Premium card → compact gold badge in navigation bar
//  Location: Features/Profile/ProfileView.swift
//

import SwiftUI
import SafariServices

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // Sheet states
    @State private var showPremiumSheet = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    // Confirmation dialog state
    @State private var confirmationInfo: ConfirmationInfo? = nil
    @State private var showConfirmation = false
    
    // Binding indices for CompactSelectorRow (derived from ViewModel)
    @State private var directionIndex: Int = 0
    @State private var themeIndex: Int = 2
    @State private var languageIndex: Int = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background gradient (unchanged from original)
                LinearGradient(
                    colors: isDarkMode ? [
                        Color(hex: "1A1625"),
                        Color(hex: "211A2E")
                    ] : [
                        Color(hex: "FBF2FF"),
                        Color(hex: "FAF1FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Ambient blur circle (unchanged from original)
                Circle()
                    .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(x: 120, y: -250)
                
                // MARK: - Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        
                        // ─── SETTINGS SECTION HEADER ───
                        sectionHeader(key: "settings_title")

                        
                        // 1. Notifications (keep SettingsCard as-is — it works perfectly)
                        SettingsCard(
                            type: .notificationToggle(
                                isOn: $viewModel.notificationsEnabled,
                                selectedHour: $viewModel.notificationTime,
                                onToggle: {
                                    viewModel.toggleNotifications()
                                },
                                onTimeChange: { hour in
                                    viewModel.changeNotificationTime(to: hour)
                                    triggerConfirmation(
                                        icon: "bell.fill",
                                        iconColor: .accentPurple,
                                        titleKey: "confirmation_notification_title",
                                        valueText: String(format: "%02d:00", hour)
                                    )
                                }
                            )
                        )
                        
                        // 2. Study Direction (compact inline buttons)
                        CompactSelectorRow(
                            icon: "arrow.left.arrow.right.circle.fill",
                            iconGradient: LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            accentColor: Color(hex: "6366F1"),
                            titleKey: "study_direction_card_title",
                            options: [
                                SelectionOption(id: 0, icon: "arrow.right.circle.fill",
                                                title: "direction_en_tr_display",
                                                value: StudyDirection.enToTr),
                                SelectionOption(id: 1, icon: "arrow.left.circle.fill",
                                                title: "direction_tr_en_display",
                                                value: StudyDirection.trToEn)
                            ],
                            selectedIndex: $directionIndex,
                            onSelectionChange: { idx in
                                let direction: StudyDirection = idx == 0 ? .enToTr : .trToEn
                                viewModel.changeStudyDirection(to: direction)
                                triggerConfirmation(
                                    icon: "arrow.left.arrow.right.circle.fill",
                                    iconColor: Color(hex: "6366F1"),
                                    titleKey: "confirmation_direction_title",
                                    valueText: localizedString(idx == 0
                                        ? "direction_en_tr_display"
                                        : "direction_tr_en_display")
                                )
                            }
                        )
                        
                        // 3. Theme (compact inline buttons — 3 options)
                        CompactSelectorRow(
                            icon: "paintbrush.fill",
                            iconGradient: LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "FB9322")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            accentColor: Color(hex: "F59E0B"),
                            titleKey: "theme_card_title",
                            options: [
                                SelectionOption(id: 0, icon: "sun.max.fill",
                                                title: "theme_light_display",
                                                value: ThemeMode.light),
                                SelectionOption(id: 1, icon: "moon.fill",
                                                title: "theme_dark_display",
                                                value: ThemeMode.dark),
                                SelectionOption(id: 2, icon: "circle.lefthalf.filled",
                                                title: "theme_system_display",
                                                value: ThemeMode.system)
                            ],
                            selectedIndex: $themeIndex,
                            onSelectionChange: { idx in
                                let theme: ThemeMode = [.light, .dark, .system][idx]
                                viewModel.changeThemeMode(to: theme)
                                themeViewModel.updateTheme(to: theme)
                                let themeKeys = [
                                    "theme_light_display",
                                    "theme_dark_display",
                                    "theme_system_display"
                                ]
                                triggerConfirmation(
                                    icon: ["sun.max.fill", "moon.fill", "circle.lefthalf.filled"][idx],
                                    iconColor: Color(hex: "F59E0B"),
                                    titleKey: "confirmation_theme_title",
                                    valueText: localizedString(themeKeys[idx])
                                )
                            }
                        )
                        
                        // 4. App Language (compact inline buttons)
                        CompactSelectorRow(
                            icon: "globe",
                            iconGradient: LinearGradient(
                                colors: [Color(hex: "06B6D4"), Color(hex: "3B82F6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            accentColor: Color(hex: "06B6D4"),
                            titleKey: "language_card_title",
                            options: [
                                SelectionOption(id: 0, icon: "globe",
                                                title: "language_english",
                                                value: AppLanguage.english),
                                SelectionOption(id: 1, icon: "globe",
                                                title: "language_turkish",
                                                value: AppLanguage.turkish)
                            ],
                            selectedIndex: $languageIndex,
                            onSelectionChange: { idx in
                                let lang: AppLanguage = idx == 0 ? .english : .turkish
                                viewModel.changeLanguage(to: lang)
                                triggerConfirmation(
                                    icon: "globe",
                                    iconColor: Color(hex: "06B6D4"),
                                    titleKey: "confirmation_language_title",
                                    valueText: localizedString(idx == 0
                                        ? "language_english"
                                        : "language_turkish")
                                )
                            }
                        )
                        
                        // ─── LEGAL & SUPPORT SECTION ───
                        sectionHeader(key: "legal_title")
                            .padding(.top, 8)
                        
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                
                // MARK: - Confirmation Dialog Overlay
                if showConfirmation, let info = confirmationInfo {
                    SelectionConfirmationDialog(info: info, isShowing: $showConfirmation)
                        .zIndex(999)
                        .transition(.opacity)
                }
            }
            .navigationTitle(Text(LocalizedStringKey("profile_welcome")))
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: premiumBadge)
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumPaywallView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/privacy-policy.html")!)
        }
        .sheet(isPresented: $showTermsOfService) {
            SafariView(url: URL(string: "https://ali-aktas.github.io/hocalingo-legal/terms-of-service.html")!)
        }
        .onAppear {
            syncIndicesFromViewModel()
        }
    }
    
    // MARK: - Premium Badge (Navigation Bar)
    private var premiumBadge: some View {
        Button(action: {
            if !viewModel.isPremium { showPremiumSheet = true }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 11, weight: .bold))
                
                Text(LocalizedStringKey(viewModel.isPremium
                    ? "premium_badge_active"
                    : "premium_badge_upgrade"))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(viewModel.isPremium ? Color(hex: "92400E") : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: viewModel.isPremium
                                ? [Color(hex: "FDE68A"), Color(hex: "FCD34D")]
                                : [Color(hex: "FFD700"), Color(hex: "FFA500")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(viewModel.isPremium)
    }
    
    // MARK: - Section Header
    private func sectionHeader(key: String) -> some View {
        HStack {
            Text(LocalizedStringKey(key))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.themeSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: 0) {
            legalRow(
                icon: "lock.shield.fill",
                iconColor: .accentPurple,
                titleKey: "legal_privacy"
            ) {
                showPrivacyPolicy = true
            }
            
            Divider()
                .background(Color.themeDivider)
                .padding(.leading, 56)
            
            legalRow(
                icon: "doc.text.fill",
                iconColor: .accentOrange,
                titleKey: "legal_terms"
            ) {
                showTermsOfService = true
            }
            
            Divider()
                .background(Color.themeDivider)
                .padding(.leading, 56)
            
            legalRow(
                icon: "envelope.fill",
                iconColor: Color(hex: "22C55E"),
                titleKey: "legal_support"
            ) {
                sendSupportEmail()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.themeCard)
                .shadow(color: Color.themeShadow, radius: 6, x: 0, y: 3)
        )
    }
    
    // MARK: - Legal Row
    private func legalRow(
        icon: String,
        iconColor: Color,
        titleKey: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon with rounded square bg
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundColor(iconColor)
                }
                
                Text(LocalizedStringKey(titleKey))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.themeTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helpers
    
    /// Sync local index states from ViewModel (called on appear)
    private func syncIndicesFromViewModel() {
        directionIndex = viewModel.studyDirection == .enToTr ? 0 : 1
        themeIndex = { switch viewModel.themeMode {
            case .light: return 0
            case .dark: return 1
            case .system: return 2
        }}()
        languageIndex = viewModel.appLanguage == .english ? 0 : 1
    }
    
    /// Trigger the confirmation overlay
    private func triggerConfirmation(
        icon: String,
        iconColor: Color,
        titleKey: String,
        valueText: String
    ) {
        confirmationInfo = ConfirmationInfo(
            icon: icon,
            iconColor: iconColor,
            titleKey: titleKey,
            valueText: valueText
        )
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showConfirmation = true
        }
    }
    
    /// Resolve a localization key to a display string
    private func localizedString(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
    
    /// Open mail app to support address
    private func sendSupportEmail() {
        let email = "auraliastudios@gmail.com"
        let subject = "HocaLingo iOS - Support Request"
        let body = "Hello HocaLingo team,\n\n"
        let mailtoString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: mailtoString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Dark Mode
    var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
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
