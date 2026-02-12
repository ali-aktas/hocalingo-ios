//
//  HomeView.swift
//  HocaLingo
//
//  🔴 REDESIGN: Study hero card → full-width immersive CTA
//  🔴 REDESIGN: Action buttons → accent bar + rounded icon + chevron
//  ✅ PRESERVED: rotatingContent, statsGrid2x2, all ViewModel connections
//  ✅ PRESERVED: all navigation, notifications, tab switching logic
//
//  Location: HocaLingo/Features/Home/HomeView.swift
//

import SwiftUI
import Combine
import Charts

// MARK: - Home View
struct HomeView: View {
    
    @Binding var selectedTab: Int
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    // Hero breathe animation
    @State private var pulseScale: CGFloat = 1.0
    @State private var heroBreathe: CGFloat = 1.0
    
    private let rotationTimer = Timer.publish(every: 40, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
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

                Circle()
                    .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                    .frame(width: 350, height: 350)
                    .blur(radius: 60)
                    .offset(x: 120, y: -250)
                
                if viewModel.uiState.isLoading {
                    ProgressView("loading")
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            titleSection
                            heroCard
                            statsTitle
                            statsGrid2x2
                            actionButtonsSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 52)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $viewModel.shouldNavigateToPackageSelection) {
                PackageSelectionView(selectedTab: $selectedTab)
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAIAssistant) {
                AIStoryMainView()
            }
            .sheet(isPresented: $viewModel.shouldShowAddWordDialog) {
                AddWordDialogView()
            }
            .onAppear {
                viewModel.loadDashboardData()
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
                print("📚 Study session completed - refreshing dashboard")
                viewModel.loadDashboardData()
            }
            .onChange(of: viewModel.shouldNavigateToStudy) { oldValue, newValue in
                if newValue {
                    selectedTab = 1
                    viewModel.shouldNavigateToStudy = false
                }
            }
        }
    }
    
    // Start gentle breathe loop for hero card glow
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
}

// MARK: - Sub-Sections
private extension HomeView {
    
    // MARK: Title (UNCHANGED)
    var titleSection: some View {
        Text("home_title")
            .font(.system(size: 32, weight: .black, design: .rounded))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: Hero Card — REDESIGNED
    // Full-width immersive CTA replaces the old half-circle button.
    // rotatingContent (mascot / motivation text) is UNCHANGED and stays on the right.
    var heroCard: some View {
        Button {
            viewModel.onEvent(.startStudy)
        } label: {
            ZStack {
                // Breathe glow layer (pulses behind the card)
                RoundedRectangle(cornerRadius: 30)
                    .fill(playButtonGlowGradient)
                    .scaleEffect(heroBreathe)
                    .blur(radius: 14)
                    .opacity(0.65)
                
                // Solid gradient background
                RoundedRectangle(cornerRadius: 28)
                    .fill(playButtonGradient)
                
                // Subtle top-edge glass highlight
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                
                // Content row
                HStack(alignment: .center, spacing: 0) {
                    
                    // Left: streak badge + headline + start pill
                    VStack(alignment: .leading, spacing: 10) {
                        streakBadge
                        
                        // Main CTA headline (⚠️ needs key in Localizable.strings)
                        Text(LocalizedStringKey("home_cta_title"))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        startPill
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 20)
                    
                    Spacer()
                    
                    // Right: rotating mascot / motivation text — UNCHANGED
                    rotatingContent
                        .padding(.trailing, 10)
                }
            }
            .frame(height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: playButtonShadowColor.opacity(0.45), radius: 22, y: 10)
        }
        .buttonStyle(SpringButtonStyle())
    }
    
    // Streak flame badge shown on the hero card
    private var streakBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(.white.opacity(0.9))
            Text("\(viewModel.uiState.streakDays)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.22))
        .clipShape(Capsule())
    }
    
    // White pill "Start" button inside the hero card
    private var startPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.system(size: 11, weight: .black))
            // ⚠️ needs "home_start_btn" key in Localizable.strings
            Text(LocalizedStringKey("home_start_btn"))
                .font(.system(size: 13, weight: .black, design: .rounded))
        }
        .foregroundColor(pillForegroundColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.white.opacity(0.28), radius: 8, y: 3)
    }
    
    // Foreground color of the white pill matches the theme accent
    private var pillForegroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "7C3AED")   // Purple tint in dark mode
            : Color(hex: "E05F00")   // Orange tint in light mode
    }
    
    // MARK: Rotating Content (UNCHANGED)
    var rotatingContent: some View {
        Group {
            switch viewModel.currentContentType {
            case .image(let index):
                mascotImage(index: index)
            case .text(let index):
                motivationTextView(index: index)
            }
        }
        .frame(width: 160, height: 120)
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .scale.combined(with: .opacity)))
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentContentType)
    }
    
    func mascotImage(index: Int) -> some View {
        let mascots = ["lingohoca1", "lingohoca2", "lingohoca3"]
        return Image(mascots[index % mascots.count])
            .resizable()
            .scaledToFit()
            .scaleEffect(1.30)
    }
    
    func motivationTextView(index: Int) -> some View {
        Text(viewModel.getMotivationText(for: index))
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: Stats (UNCHANGED)
    var statsTitle: some View {
        Text("stat_monthly_stats")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var statsGrid2x2: some View {
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
                    chartData: generateActiveDaysChartData()
                )
            }
            HStack(spacing: 12) {
                StatCardWithChart(
                    title: "stat_this_month_time",
                    value: viewModel.uiState.monthlyStats.formattedStudyTime,
                    icon: "clock.fill",
                    gradient: [Color(hex: "67E8F9"), Color(hex: "22D3EE")],
                    chartData: generateStudyTimeChartData()
                )
                StatCardWithChart(
                    title: "stat_discipline_score",
                    value: "\(viewModel.uiState.monthlyStats.disciplineScore)%",
                    icon: "star.fill",
                    gradient: [Color(hex: "FDBA74"), Color(hex: "FB923C")],
                    chartData: generateDisciplineChartData()
                )
            }
        }
    }
    
    // MARK: Action Buttons — REDESIGNED
    // IDs, titles, subtitles, accentColors, actions: ALL UNCHANGED.
    // Visual treatment redesigned: accent bar + rounded icon + chevron.
    var actionButtonsSection: some View {
        VStack(spacing: 12) {
            ActionButtonWithIcon(
                iconName: "card_icon",
                title: "action_select_package",
                subtitle: "action_select_package_desc",
                accentColor: .accentTeal,
                action: { viewModel.onEvent(.navigateToPackageSelection) }
            )
            ActionButtonWithIcon(
                iconName: "add_img",
                title: "action_add_word",
                subtitle: "action_add_word_desc",
                accentColor: .accentOrange,
                action: { viewModel.onEvent(.showAddWordDialog) }
            )
            ActionButtonWithIcon(
                iconName: "ai_icon",
                title: "action_ai_assistant",
                subtitle: "action_ai_assistant_desc",
                accentColor: .accentPurple,
                action: { viewModel.onEvent(.navigateToAIAssistant) }
            )
        }
    }
}

// MARK: - Stat Card (UNCHANGED)
struct StatCardWithChart: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    let gradient: [Color]
    let chartData: [Double]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            headerSection
            valueSection
            Spacer(minLength: 0)
            chartSection
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background((gradient.first ?? .blue).opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke((gradient.first ?? .blue).opacity(0.2), lineWidth: 1.2))
        .frame(height: 120)
    }
    
    private var headerSection: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(gradient.first ?? .blue)
                .frame(width: 24, height: 24)
                .background((gradient.first ?? .blue).opacity(0.1))
                .clipShape(Circle())
            
            Text(LocalizedStringKey(title))
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
    
    private var valueSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
            
            if !subtitle.isEmpty {
                Text(LocalizedStringKey(subtitle))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var chartSection: some View {
        Chart {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                AreaMark(x: .value("Index", index), y: .value("Value", point))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(areaGradient)
                
                LineMark(x: .value("Index", index), y: .value("Value", point))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(gradient.first ?? .blue)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(height: 30)
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [(gradient.first ?? .blue).opacity(0.4), (gradient.first ?? .blue).opacity(0.01)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Action Button — REDESIGNED
// Accent bar + rounded-rect icon + chevron → higher perceived tappability
struct ActionButtonWithIcon: View {
    let iconName: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let accentColor: Color
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                
                // Left accent bar — color stripe communicates category at a glance
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                    .padding(.vertical, 14)
                
                // Icon in rounded-rect container
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 38)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(accentColor.opacity(isDark ? 0.18 : 0.12))
                    )
                    .padding(.leading, 14)
                    .padding(.trailing, 12)
                
                // Title + subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.themeSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 8)
                
                // Chevron in soft accent circle → strong tappability signal
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accentColor)
                    .frame(width: 30, height: 30)
                    .background(accentColor.opacity(isDark ? 0.15 : 0.1))
                    .clipShape(Circle())
                    .padding(.trailing, 16)
            }
            .padding(.vertical, 12)
            .background(Color.themeCard)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(accentColor.opacity(isDark ? 0.22 : 0.32), lineWidth: isDark ? 0.8 : 1.0)
            )
            .shadow(color: accentColor.opacity(isDark ? 0.0 : 0.07), radius: 8, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var isDark: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Gradients & Chart Data (private helpers)
private extension HomeView {
    
    var playButtonGradient: LinearGradient {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        return isDark
            ? LinearGradient(colors: [Color(hex: "9333EA"), Color(hex: "7C3AED")], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: "FB9322"), Color(hex: "FF6B00")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    var playButtonGlowGradient: LinearGradient {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        let color = isDark ? Color(hex: "9333EA") : Color(hex: "FB9322")
        return LinearGradient(colors: [color.opacity(0.45), color.opacity(0.1)], startPoint: .top, endPoint: .bottom)
    }
    
    var playButtonShadowColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "9333EA").opacity(0.4)
            : Color(hex: "FB9322").opacity(0.4)
    }
    
    func generateStreakChartData() -> [Double] {
        [3, 4, 5, 6, 7, Double(viewModel.uiState.streakDays)]
    }
    func generateActiveDaysChartData() -> [Double] {
        let d = Double(viewModel.uiState.monthlyStats.activeDaysThisMonth)
        return [d * 0.3, d * 0.5, d * 0.7, d * 0.85, d * 0.95, d]
    }
    func generateStudyTimeChartData() -> [Double] {
        let t = Double(viewModel.uiState.monthlyStats.studyTimeThisMonth)
        return [t * 0.2, t * 0.4, t * 0.6, t * 0.8, t * 0.9, t]
    }
    func generateDisciplineChartData() -> [Double] {
        let s = Double(viewModel.uiState.monthlyStats.disciplineScore)
        return [s * 0.4, s * 0.6, s * 0.75, s * 0.85, s * 0.92, s]
    }
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Button Styles
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
