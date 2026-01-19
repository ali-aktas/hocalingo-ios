//
//  HomeView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN v2.0 - OPTIMIZED:
//  - Larger play button with reduced spacing
//  - Lower stats cards (120dp) with proper spacing
//  - Horizontal text layout in stats cards
//  - Optimized paddings throughout
//
//  Location: HocaLingo/Features/Home/HomeView.swift
//

import SwiftUI
import Combine
import Charts  // ✅ iOS 17+ Charts framework

// MARK: - Home View
/// Premium Home Dashboard - Production-grade with motivation rotation
struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    // ✅ Timer for 40-second rotation
    private let rotationTimer = Timer.publish(every: 40, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.uiState.isLoading {
                    ProgressView(NSLocalizedString("loading", comment: ""))
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {  // ✅ Reduced from 42
                            
                            // 1. HocaLingo Title (CENTER + BLACK)
                            titleSection
                            
                            // 2. Hero card (Play + Image/Motivation rotation)
                            heroCard
                            
                            // 3. Monthly Stats Title
                            statsTitle
                            
                            // 4. 2x2 Stats Grid (Premium cards with mini charts)
                            statsGrid2x2
                            
                            // 5. Action buttons (with PNGs)
                            actionButtonsSection
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 52) // Space for bottom nav
                    }
                }
            }
            .navigationBarHidden(true)
            // Navigation destinations
            .navigationDestination(isPresented: $viewModel.shouldNavigateToStudy) {
                StudyView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToPackageSelection) {
                PackageSelectionView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAIAssistant) {
                Text("AI Assistant - Coming Soon!")
                    .font(.title)
                    .padding()
            }
            // Add Word Dialog
            .sheet(isPresented: $viewModel.shouldShowAddWordDialog) {
                AddWordDialogView()
            }
            // 40-second rotation
            .onReceive(rotationTimer) { _ in
                viewModel.rotateHeroContent()
            }
            // ✅ Language change listener
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AppLanguageChanged"))) { _ in
                viewModel.loadDashboardData()
            }
        }
    }
}

// MARK: - Title Section
private extension HomeView {
    var titleSection: some View {
        Text(NSLocalizedString("home_title", comment: ""))
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Hero Card (Play Button + Image/Motivation Rotation)
private extension HomeView {
    var heroCard: some View {
        HStack(alignment: .center, spacing: 8) {  // ✅ Reduced spacing from 16 to 8
            
            // ✅ LEFT: Play Button (120x120, larger)
            playButton
            
            Spacer()
            
            // ✅ RIGHT: Rotating Content (Image or Motivation Text)
            rotatingContent
            
        }
    }
    
    var playButton: some View {
        Button {
            viewModel.onEvent(.startStudy)
        } label: {
            ZStack {
                // Glow effect
                Circle()
                    .fill(playButtonGlowGradient)
                    .frame(width: 140, height: 140)  // ✅ Increased
                    .blur(radius: 10)
                
                // Main circle (theme-aware)
                Circle()
                    .fill(playButtonGradient)
                    .frame(width: 120, height: 120)  // ✅ Increased from 100
                    .shadow(color: playButtonShadowColor, radius: 12, y: 6)
                
                // Play icon
                Image(systemName: "play.fill")
                    .font(.system(size: 42, weight: .bold))  // ✅ Increased from 36
                    .foregroundColor(.white)
                    .offset(x: 3)
            }
        }
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
        .frame(width: 160, height: 120)  // ✅ Adjusted height to match button
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentContentType)
    }
    
    func mascotImage(index: Int) -> some View {
        let mascots = ["lingohoca1", "lingohoca2", "lingohoca3"]
        return Image(mascots[index % mascots.count])
            .resizable()
            .scaledToFit()
    }
    
    func motivationTextView(index: Int) -> some View {
        Text(viewModel.getMotivationText(for: index))
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    // ✅ THEME-AWARE COLORS
    var playButtonGradient: LinearGradient {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        if isDark {
            // Dark mode: Purple
            return LinearGradient(
                colors: [Color(hex: "9333EA"), Color(hex: "7C3AED")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Light mode: Orange
            return LinearGradient(
                colors: [Color(hex: "FB9322"), Color(hex: "FF6B00")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var playButtonGlowGradient: LinearGradient {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        if isDark {
            return LinearGradient(
                colors: [Color(hex: "9333EA").opacity(0.3), Color(hex: "9333EA").opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "FB9322").opacity(0.3), Color(hex: "FB9322").opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var playButtonShadowColor: Color {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        return isDark ? Color(hex: "9333EA").opacity(0.4) : Color(hex: "FB9322").opacity(0.4)
    }
}

// MARK: - Stats Title
private extension HomeView {
    var statsTitle: some View {
        Text(NSLocalizedString("stat_monthly_stats", comment: ""))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 2x2 Stats Grid (Reference Image Style)
private extension HomeView {
    var statsGrid2x2: some View {
        VStack(spacing: 12) {  // ✅ Fixed spacing (from 52 to 12)
            // Row 1
            HStack(spacing: 12) {
                // Streak Card (Purple gradient)
                StatCardWithChart(
                    title: NSLocalizedString("stat_streak_days", comment: ""),
                    value: "\(viewModel.uiState.streakDays)",
                    icon: "flame.fill",
                    gradient: [Color(hex: "A78BFA"), Color(hex: "8B5CF6")],
                    chartData: generateStreakChartData(),
                    chartColor: Color.white.opacity(0.3)
                )
                
                // Active Days Card (Pink gradient)
                StatCardWithChart(
                    title: NSLocalizedString("stat_active_days", comment: ""),
                    value: "\(viewModel.uiState.monthlyStats.activeDaysThisMonth)",
                    icon: "calendar.badge.checkmark",
                    gradient: [Color(hex: "F9A8D4"), Color(hex: "F472B6")],
                    chartData: generateActiveDaysChartData(),
                    chartColor: Color.white.opacity(0.3)
                )
            }
            
            // Row 2
            HStack(spacing: 12) {
                // Study Time Card (Cyan gradient)
                StatCardWithChart(
                    title: NSLocalizedString("stat_this_month_time", comment: ""),
                    value: "\(viewModel.uiState.monthlyStats.studyTimeThisMonth)",
                    subtitle: NSLocalizedString("stat_study_time_min", comment: ""),
                    icon: "clock.fill",
                    gradient: [Color(hex: "67E8F9"), Color(hex: "22D3EE")],
                    chartData: generateStudyTimeChartData(),
                    chartColor: Color.white.opacity(0.3)
                )
                
                // Discipline Score Card (Orange gradient)
                StatCardWithChart(
                    title: NSLocalizedString("stat_discipline_score", comment: ""),
                    value: "\(viewModel.uiState.monthlyStats.disciplineScore)%",
                    icon: "star.fill",
                    gradient: [Color(hex: "FDBA74"), Color(hex: "FB923C")],
                    chartData: generateDisciplineChartData(),
                    chartColor: Color.white.opacity(0.3)
                )
            }
        }
    }
    
    // Chart data generators (simple trend lines)
    func generateStreakChartData() -> [Double] {
        // Simple upward trend
        return [3, 4, 5, 6, 7, Double(viewModel.uiState.streakDays)]
    }
    
    func generateActiveDaysChartData() -> [Double] {
        // Monthly progress
        let days = Double(viewModel.uiState.monthlyStats.activeDaysThisMonth)
        return [days * 0.3, days * 0.5, days * 0.7, days * 0.85, days * 0.95, days]
    }
    
    func generateStudyTimeChartData() -> [Double] {
        // Study time trend
        let time = Double(viewModel.uiState.monthlyStats.studyTimeThisMonth)
        return [time * 0.2, time * 0.4, time * 0.6, time * 0.8, time * 0.9, time]
    }
    
    func generateDisciplineChartData() -> [Double] {
        // Discipline trend
        let score = Double(viewModel.uiState.monthlyStats.disciplineScore)
        return [score * 0.4, score * 0.6, score * 0.75, score * 0.85, score * 0.92, score]
    }
}

// MARK: - Action Buttons (With PNGs)
private extension HomeView {
    var actionButtonsSection: some View {
        VStack(spacing: 12) {
            
            // 1. Package Selection Button (Teal/Turkuaz)
            ActionButtonWithIcon(
                iconName: "card_icon",
                title: NSLocalizedString("action_select_package", comment: ""),
                subtitle: NSLocalizedString("action_select_package_desc", comment: ""),
                baseColor: Color(hex: "14B8A6"),  // ✅ Teal
                action: { viewModel.onEvent(.navigateToPackageSelection) }
            )
            
            // 2. Add Word Button (Rose/Pembe)
            ActionButtonWithIcon(
                iconName: "add_img",
                title: NSLocalizedString("action_add_word", comment: ""),
                subtitle: NSLocalizedString("action_add_word_desc", comment: ""),
                baseColor: Color(hex: "F43F5E"),  // ✅ Rose
                action: { viewModel.onEvent(.showAddWordDialog) }
            )
            
            // 3. AI Assistant Button (Indigo/Mavi-Mor)
            ActionButtonWithIcon(
                iconName: "ai_icon",
                title: NSLocalizedString("action_ai_assistant", comment: ""),
                subtitle: NSLocalizedString("action_ai_assistant_desc", comment: ""),
                baseColor: Color(hex: "6366F1"),  // ✅ Indigo
                action: { viewModel.onEvent(.navigateToAIAssistant) }
            )
        }
    }
}

// MARK: - Stat Card With Mini Chart (2x2 Grid Style)
struct StatCardWithChart: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    let gradient: [Color]
    let chartData: [Double]
    let chartColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {  // ✅ Reduced spacing
            
            // Top: Icon
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))  // ✅ Slightly smaller
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 28, height: 28)  // ✅ Smaller
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // ✅ NEW: Value and Title in same row (HORIZONTAL)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 12, weight: .bold))  // ✅ Slightly smaller
                    .foregroundColor(.white)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Mini Chart
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Value", point)
                    )
                    .foregroundStyle(chartColor)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 25)  // ✅ Smaller chart
        }
        .padding(12)  // ✅ Reduced padding
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(height: 120)  // ✅ Reduced from 140 to 120
    }
}

// MARK: - Action Button With Icon (PNG from Assets)
struct ActionButtonWithIcon: View {
    let iconName: String
    let title: String
    let subtitle: String
    let baseColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                // ✅ PNG Icon (left side)
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [baseColor, baseColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: baseColor.opacity(0.3), radius: isPressed ? 6 : 12, y: isPressed ? 2 : 6)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
