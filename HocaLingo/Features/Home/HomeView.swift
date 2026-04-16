//
//  HomeView.swift
//  HocaLingo
//
//  Thin orchestrator — all heavy UI lives in HomeComponents.swift
//  ✅ FIXED: @AppStorage added for reactive language switching
//  ✅ UPDATED: Streak badge moved to stats header, glow reduced, chart data safe
//  Location: Features/Home/HomeView.swift
//

import SwiftUI
import Combine

// MARK: - Home View
struct HomeView: View {

    @Binding var selectedTab: Int

    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var vaultVM   = WordVaultViewModel()

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    // ✅ Triggers SwiftUI re-render when language changes
    @AppStorage("app_language") private var appLanguageCode: String = "en"

    @State private var heroBreathe: CGFloat  = 1.0
    @State private var showVaultSheet: Bool  = false

    private let rotationTimer = Timer.publish(every: 20, on: .main, in: .common).autoconnect()
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: isDarkMode
                        ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                        : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Ambient glow circle (reduced intensity)
                Circle()
                    .fill(Color.accentPurple.opacity(isDarkMode ? 0.10 : 0.05))
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(x: 120, y: -250)

                // Content
                if viewModel.uiState.isLoading {
                    ProgressView(LocalizedStringKey("loading"))
                } else {
                    mainScroll
                }
            }
            .navigationBarHidden(true)
            // Navigation destinations
            .sheet(isPresented: $viewModel.shouldNavigateToPackageSelection) {
                PackageSelectionView(selectedTab: $selectedTab)
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAIAssistant) {
                AIStoryMainView()
            }
            // Sheets
            .sheet(isPresented: $viewModel.shouldShowAddWordDialog) {
                AddWordDialogView()
            }
            .sheet(isPresented: $showVaultSheet) {
                WordVaultSheet(vaultVM: vaultVM)
            }
            // Lifecycle
            .onAppear {
                viewModel.loadDashboardData()
                vaultVM.load()
                checkAINotificationNavigation()
                startHeroAnimation()
            }
            .onReceive(rotationTimer) { _ in
                viewModel.rotateHeroContent()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppLanguageChanged"))) { _ in
                viewModel.loadDashboardData()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("StudySessionCompleted"))) { _ in
                viewModel.loadDashboardData()
                vaultVM.reload()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WordsChanged"))) { _ in
                vaultVM.reload()
            }
            .onChange(of: viewModel.shouldNavigateToStudy) { _, newValue in
                if newValue {
                    selectedTab = 1
                    viewModel.shouldNavigateToStudy = false
                }
            }
        }
    }

    // MARK: - Main Scroll
    private var mainScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {

                // Title
                Text(LocalizedStringKey("home_title"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Hero card (CTA)
                HeroCardView(
                    uiState: viewModel.uiState,
                    currentContentType: viewModel.currentContentType,
                    heroBreathe: heroBreathe,
                    isDark: isDarkMode,
                    onTap: { viewModel.onEvent(.startStudy) }
                )

                // Monthly stats title + streak badge (moved here from hero card)
                statsHeader

                // Stats 2×2 grid
                statsGrid

                // Action buttons (Package + AddWord)
                HomeActionButtonsSection(
                    onPackageSelect: { viewModel.onEvent(.navigateToPackageSelection) },
                    onAddWord:       { viewModel.onEvent(.showAddWordDialog) }
                )

                // Kelime Kasam preview row
                VaultPreviewRow(
                    vaultVM: vaultVM,
                    onShowAll: { showVaultSheet = true },
                    isDark: isDarkMode
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 52)
        }
    }

    // MARK: - Stats Header (title + streak badge)
    private var statsHeader: some View {
        HStack {
            Text(LocalizedStringKey("stat_monthly_stats"))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            Spacer()

            // Streak badge (relocated from hero card)
            streakBadge
        }
    }

    // MARK: - Streak Badge
    private var streakBadge: some View {
        let streak = viewModel.uiState.currentStreak
        return HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(streakFlameColor(for: streak))
            Text("\(streak)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.85))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(streakBadgeBackground(for: streak))
        .clipShape(Capsule())
    }

    // MARK: - Streak Colors
    private func streakFlameColor(for streak: Int) -> Color {
        switch streak {
        case 0:        return .secondary
        case 1...4:    return Color(hex: "FCD34D")
        case 5...9:    return Color(hex: "FBBF24")
        case 10...14:  return Color(hex: "F59E0B")
        case 15...19:  return Color(hex: "F97316")
        case 20...29:  return Color(hex: "EF4444")
        default:       return Color(hex: "DC2626")
        }
    }

    private func streakBadgeBackground(for streak: Int) -> Color {
        let base: Color
        switch streak {
        case 0:        base = .secondary
        case 1...4:    base = Color(hex: "FCD34D")
        case 5...9:    base = Color(hex: "FBBF24")
        case 10...14:  base = Color(hex: "F59E0B")
        case 15...19:  base = Color(hex: "F97316")
        case 20...29:  base = Color(hex: "EF4444")
        default:       base = Color(hex: "DC2626")
        }
        return base.opacity(isDarkMode ? 0.20 : 0.12)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCardWithChart(
                    title: "stat_learned_words",
                    value: "\(viewModel.uiState.streakDays)",
                    icon: "checkmark.seal.fill",
                    gradient: [Color(hex: "A78BFA"), Color(hex: "8B5CF6")],
                    chartData: generateStreakChartData()
                )
                StatCardWithChart(
                    title: "stat_active_days",
                    value: "\(viewModel.uiState.monthlyStats.activeDaysThisMonth)",
                    icon: "calendar.badge.checkmark",
                    gradient: [Color(hex: "F9A8D4"), Color(hex: "F472B6")],
                    chartData: generateActiveDaysData()
                )
            }
            HStack(spacing: 12) {
                StatCardWithChart(
                    title: "stat_this_month_time",
                    value: viewModel.uiState.monthlyStats.formattedStudyTime,
                    icon: "clock.fill",
                    gradient: [Color(hex: "67E8F9"), Color(hex: "22D3EE")],
                    chartData: generateStudyTimeData()
                )
                StatCardWithChart(
                    title: "stat_discipline_score",
                    value: "\(viewModel.uiState.monthlyStats.disciplineScore)%",
                    icon: "star.fill",
                    gradient: [Color(hex: "FDBA74"), Color(hex: "FB923C")],
                    chartData: generateDisciplineData()
                )
            }
        }
    }

    // MARK: - Helpers
    private func startHeroAnimation() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            heroBreathe = 1.06
        }
    }

    private func checkAINotificationNavigation() {
        if UserDefaults.standard.bool(forKey: "should_navigate_to_ai") {
            UserDefaults.standard.set(false, forKey: "should_navigate_to_ai")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.shouldNavigateToAIAssistant = true
            }
        }
    }

    // MARK: - Sparkline Data Generators (safe for zero values)

    private func generateStreakChartData() -> [Double] {
        let v = Double(viewModel.uiState.streakDays)
        guard v > 0 else { return [0, 0, 0, 0, 0, 0] }
        return [v * 0.3, v * 0.5, v * 0.65, v * 0.8, v * 0.92, v]
    }

    private func generateActiveDaysData() -> [Double] {
        let d = Double(viewModel.uiState.monthlyStats.activeDaysThisMonth)
        guard d > 0 else { return [0, 0, 0, 0, 0, 0] }
        return [d * 0.3, d * 0.5, d * 0.7, d * 0.85, d * 0.95, d]
    }

    private func generateStudyTimeData() -> [Double] {
        let t = Double(viewModel.uiState.monthlyStats.studyTimeThisMonth)
        guard t > 0 else { return [0, 0, 0, 0, 0, 0] }
        return [t * 0.2, t * 0.4, t * 0.6, t * 0.8, t * 0.9, t]
    }

    private func generateDisciplineData() -> [Double] {
        let s = Double(viewModel.uiState.monthlyStats.disciplineScore)
        guard s > 0 else { return [0, 0, 0, 0, 0, 0] }
        return [s * 0.4, s * 0.6, s * 0.75, s * 0.85, s * 0.92, s]
    }
}
