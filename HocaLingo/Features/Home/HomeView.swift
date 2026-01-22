//
//  HomeView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX: Tab switching instead of navigation (DESIGN UNCHANGED)
//  ✅ COMPILER FIX: Refactored StatCardWithChart to avoid type-check timeout
//  ✅ LOCALIZATION: All NSLocalizedString replaced with clean keys for instant update
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
    
    @State private var pulseScale: CGFloat = 1.0
    private let rotationTimer = Timer.publish(every: 40, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
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
                PackageSelectionView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAIAssistant) {
                Text("AI Assistant - Coming Soon!")
                    .font(.title)
                    .padding()
            }
            .sheet(isPresented: $viewModel.shouldShowAddWordDialog) {
                AddWordDialogView()
            }
            .onReceive(rotationTimer) { _ in
                viewModel.rotateHeroContent()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppLanguageChanged"))) { _ in
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
}

// MARK: - Sub-Sections
private extension HomeView {
    var titleSection: some View {
        Text("home_title")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var heroCard: some View {
        HStack(alignment: .center, spacing: 8) {
            playButton.padding(.leading, 10)
            Spacer()
            rotatingContent.padding(.trailing, 10)
        }
    }

    var playButton: some View {
        Button {
            viewModel.onEvent(.startStudy)
        } label: {
            ZStack {
                Circle()
                    .fill(playButtonGlowGradient)
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)
                
                Circle()
                    .fill(playButtonGradient)
                    .frame(width: 120, height: 120)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                    .shadow(color: playButtonShadowColor, radius: 15, y: 10)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 4)
            }
        }
        .buttonStyle(SpringButtonStyle())
    }
    
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
            .scaleEffect(1.90)
    }
    
    func motivationTextView(index: Int) -> some View {
        Text(viewModel.getMotivationText(for: index))
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    var statsTitle: some View {
        Text("stat_monthly_stats")
            .font(.system(size: 16, weight: .bold))
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
                    value: viewModel.uiState.monthlyStats.formattedStudyTime,  // ✅ Shows "2h 0m"
                    // Remove subtitle: "stat_study_time_min" - no longer needed
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

// MARK: - Stat Card (Refactored for Performance)
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
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(gradient.first ?? .blue)
                .frame(width: 24, height: 24)
                .background((gradient.first ?? .blue).opacity(0.1))
                .clipShape(Circle())
            
            Text(LocalizedStringKey(title))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
    
    private var valueSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.primary)
            
            if !subtitle.isEmpty {
                Text(LocalizedStringKey(subtitle))
                    .font(.system(size: 12, weight: .bold))
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

// MARK: - Action Button (FIXED FOR LIGHT THEME)
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
            HStack(spacing: 18) {
                // Icon with better contrast
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(accentColor.opacity(isDark ? 0.2 : 0.15)) // ✅ Adjusted for light theme
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.themePrimary)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.themeCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        accentColor.opacity(isDark ? 0.3 : 0.4), // ✅ Increased from 0.2 to 0.4 for light theme
                        lineWidth: isDark ? 0.5 : 1.0  // ✅ Thicker border in light theme
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // Helper computed property
    private var isDark: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Styles & Gradients
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
        return LinearGradient(colors: [color.opacity(0.3), color.opacity(0.1)], startPoint: .top, endPoint: .bottom)
    }
    
    var playButtonShadowColor: Color {
        themeViewModel.isDarkMode(in: colorScheme) ? Color(hex: "9333EA").opacity(0.4) : Color(hex: "FB9322").opacity(0.4)
    }
    
    func generateStreakChartData() -> [Double] { [3, 4, 5, 6, 7, Double(viewModel.uiState.streakDays)] }
    func generateActiveDaysChartData() -> [Double] {
        let days = Double(viewModel.uiState.monthlyStats.activeDaysThisMonth)
        return [days * 0.3, days * 0.5, days * 0.7, days * 0.85, days * 0.95, days]
    }
    func generateStudyTimeChartData() -> [Double] {
        let time = Double(viewModel.uiState.monthlyStats.studyTimeThisMonth)
        return [time * 0.2, time * 0.4, time * 0.6, time * 0.8, time * 0.9, time]
    }
    func generateDisciplineChartData() -> [Double] {
        let score = Double(viewModel.uiState.monthlyStats.disciplineScore)
        return [score * 0.4, score * 0.6, score * 0.75, score * 0.85, score * 0.92, score]
    }
}

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
