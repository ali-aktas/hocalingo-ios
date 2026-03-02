//
//  HomeView.swift
//  HocaLingo
//
//  Thin orchestrator — all heavy UI lives in HomeComponents.swift
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

                Circle()
                    .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
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
            .navigationDestination(isPresented: $viewModel.shouldNavigateToPackageSelection) {
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

                // Monthly stats title
                Text(LocalizedStringKey("stat_monthly_stats"))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

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

    // Sparkline data generators (same logic as before)
    private func generateStreakChartData() -> [Double] {
        [3, 4, 5, 6, 7, Double(viewModel.uiState.streakDays)]
    }
    private func generateActiveDaysData() -> [Double] {
        let d = Double(viewModel.uiState.monthlyStats.activeDaysThisMonth)
        return [d*0.3, d*0.5, d*0.7, d*0.85, d*0.95, d]
    }
    private func generateStudyTimeData() -> [Double] {
        let t = Double(viewModel.uiState.monthlyStats.studyTimeThisMonth)
        return [t*0.2, t*0.4, t*0.6, t*0.8, t*0.9, t]
    }
    private func generateDisciplineData() -> [Double] {
        let s = Double(viewModel.uiState.monthlyStats.disciplineScore)
        return [s*0.4, s*0.6, s*0.75, s*0.85, s*0.92, s]
    }
}
