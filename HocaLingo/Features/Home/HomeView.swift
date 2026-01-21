//
//  HomeView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX: Tab switching instead of navigation (DESIGN UNCHANGED)
//  - Added @Binding selectedTab from MainTabView
//  - Play button switches to Study tab (1) instead of navigating
//  - All original design preserved
//
//  Location: HocaLingo/Features/Home/HomeView.swift
//

import SwiftUI
import Combine
import Charts  // ✅ iOS 17+ Charts framework

// MARK: - Home View
/// Premium Home Dashboard - Production-grade with motivation rotation
struct HomeView: View {
    
    // ✅ CRITICAL FIX: Accept tab selection binding from MainTabView
    @Binding var selectedTab: Int
    
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var pulseScale: CGFloat = 1.0
    
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
            // ✅ REMOVED: .navigationDestination for StudyView (we switch tabs instead!)
            // Navigation destinations (keep only non-Study ones)
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
            // ✅ CRITICAL FIX: Listen for shouldNavigateToStudy and switch tab instead
            .onChange(of: viewModel.shouldNavigateToStudy) { oldValue, newValue in
                if newValue {
                    // Switch to Study tab (tab 1)
                    selectedTab = 1
                    // Reset flag
                    viewModel.shouldNavigateToStudy = false
                }
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

// MARK: - Seçenek 3: Yaylanma Hissi (Spring)
private extension HomeView {
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
                // Parlama efekti
                Circle()
                    .fill(playButtonGlowGradient)
                    .frame(width: 140, height: 140)
                    .blur(radius: 10)
                
                // Ana Buton
                Circle()
                    .fill(playButtonGradient)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 2) // Şık kenarlık
                    )
                    .shadow(color: playButtonShadowColor, radius: 15, y: 10)
                
                Image(systemName: "play.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 4)
            }
        }
        .buttonStyle(SpringButtonStyle()) // Özel basma efekti
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
                // İkonları ve başlıkları senin renk sisteminden besler
                ActionButtonWithIcon(
                    iconName: "card_icon",
                    title: NSLocalizedString("action_select_package", comment: ""),
                    subtitle: NSLocalizedString("action_select_package_desc", comment: ""),
                    accentColor: .accentTeal,
                    action: { viewModel.onEvent(.navigateToPackageSelection) }
                )
                
                ActionButtonWithIcon(
                    iconName: "add_img",
                    title: NSLocalizedString("action_add_word", comment: ""),
                    subtitle: NSLocalizedString("action_add_word_desc", comment: ""),
                    accentColor: .accentOrange,
                    action: { viewModel.onEvent(.showAddWordDialog) }
                )
                
                ActionButtonWithIcon(
                    iconName: "ai_icon",
                    title: NSLocalizedString("action_ai_assistant", comment: ""),
                    subtitle: NSLocalizedString("action_ai_assistant_desc", comment: ""),
                    accentColor: .accentPurple,
                    action: { viewModel.onEvent(.navigateToAIAssistant) }
                )
            }
        }
}

// MARK: - Stat Card With Mini Chart (2x2 Grid Style - Curved Area Design)
struct StatCardWithChart: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    let gradient: [Color]
    let chartData: [Double]
    let chartColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Top: Icon and Title
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(gradient.first ?? .blue)
                    .frame(width: 24, height: 24)
                    .background((gradient.first ?? .blue).opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            // Middle: Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.primary)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 0)
            
            // Bottom: Curved Area Chart
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                    // 1. Alt dolgu alanı (Area)
                    AreaMark(
                        x: .value("Index", index),
                        y: .value("Value", point)
                    )
                    .interpolationMethod(.catmullRom) // ✅ Kavisli yapma
                    .foregroundStyle(
                        LinearGradient(
                            colors: [(gradient.first ?? .blue).opacity(0.4), (gradient.first ?? .blue).opacity(0.01)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // 2. Üst belirgin çizgi (Line)
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Value", point)
                    )
                    .interpolationMethod(.catmullRom) // ✅ Kavisli yapma
                    .foregroundStyle(gradient.first ?? .blue)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 30) // Area göründüğü için yüksekliği çok az (5 birim) artırdım
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            (gradient.first ?? .blue).opacity(0.04)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke((gradient.first ?? .blue).opacity(0.2), lineWidth: 1.2)
        )
        .frame(height: 120)
    }
}
// MARK: - Action Button With Icon (PNG from Assets)
struct ActionButtonWithIcon: View {
    let iconName: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(accentColor.opacity(0.1))
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
                // Sadece seçilen aksan renginde çok hafif bir parlama
                RoundedRectangle(cornerRadius: 22)
                    .stroke(accentColor.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Bu yardımcı kod parçasını dosyanın en altına (en dışa) ekleyebilirsin
struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0), value: configuration.isPressed)
    }
}

// Tıklama efekti (Her yerde kullanılabilir)
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    HomeView(selectedTab: .constant(0))
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
