//
//  HomeViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Navigation logic + Monthly stats - matches Android HomeViewModel v2.1
//  Location: HocaLingo/Features/Home/HomeViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Home View Model
/// Business logic for home dashboard - production-grade with Android parity
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var uiState = HomeUiState()
    
    // ✅ NEW: Navigation triggers
    @Published var shouldNavigateToStudy: Bool = false
    @Published var shouldNavigateToPackageSelection: Bool = false
    @Published var shouldNavigateToAIAssistant: Bool = false
    @Published var shouldShowAddWordDialog: Bool = false
    
    // MARK: - Motivational Texts
    private let motivationTexts = [
        "Your English adventure awaits",
        "New words, new opportunities",
        "You're one step closer to your goal",
        "What story will you write today?",
        "Motivation is high, let's start",
        "Success comes with patience, keep going",
        "Every study session is a victory",
        "Ready to learn today?",
        "Welcome to the world of English",
        "Keep the momentum going!"
    ]
    
    // MARK: - Computed Properties
    
    /// Greeting text based on time of day
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return NSLocalizedString("home_greeting_morning", comment: "")
        case 12..<17:
            return NSLocalizedString("home_greeting_afternoon", comment: "")
        case 17..<22:
            return NSLocalizedString("home_greeting_evening", comment: "")
        default:
            return NSLocalizedString("home_greeting_night", comment: "")
        }
    }
    
    /// Daily motivation text (rotates by day of year)
    var motivationText: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return motivationTexts[dayOfYear % motivationTexts.count]
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    private let soundManager = SoundManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadDashboardData()
        trackAppLaunch()
        checkPremiumStatus()
    }
    
    // MARK: - Data Loading
    
    /// Load all dashboard data
    func loadDashboardData() {
        uiState.isLoading = true
        
        // Load user stats
        let stats = userDefaults.loadUserStats()
        
        // Update streak
        uiState.streakDays = stats.currentStreak
        
        // Load today's graduation count
        let todayStats = userDefaults.getTodayDailyStats()
        
        // Update daily goal progress
        let dailyGoal = userDefaults.loadDailyGoal()
        uiState.dailyGoalProgress = DailyGoalProgress(
            currentWords: todayStats.wordsGraduated,
            targetWords: dailyGoal
        )
        
        // ✅ NEW: Load monthly stats (Android parity)
        loadMonthlyStats()
        
        // Get user name (if available)
        uiState.userName = userDefaults.loadUserName() ?? "HocaLingo User"
        
        uiState.isLoading = false
        
        print("✅ Dashboard data loaded:")
        print("   - Streak: \(uiState.streakDays) days")
        print("   - Daily progress: \(todayStats.wordsGraduated)/\(dailyGoal)")
        print("   - Monthly days: \(uiState.monthlyStats.activeDaysThisMonth)")
    }
    
    /// ✅ NEW: Load monthly statistics (Android parity)
    private func loadMonthlyStats() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start and end of current month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return
        }
        
        // Date formatter for daily stats
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        var activeDays = 0
        var totalMinutes = 0
        
        // Iterate through each day of the current month
        var currentDate = monthStart
        while currentDate <= min(monthEnd, now) {
            let dateString = dateFormatter.string(from: currentDate)
            
            // Load stats for this date
            if let dayStats = userDefaults.loadDailyStats(for: dateString) {
                if dayStats.wordsStudied > 0 {
                    activeDays += 1
                }
                totalMinutes += dayStats.studyTimeMinutes
            }
            
            // Move to next day
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        // Update UI state
        uiState.monthlyStats = MonthlyStats(
            activeDaysThisMonth: activeDays,
            studyTimeThisMonth: totalMinutes,
            disciplineScore: calculateDisciplineScore(activeDays: activeDays)
        )
    }
    
    /// Calculate discipline score (0-100)
    private func calculateDisciplineScore(activeDays: Int) -> Int {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: Date())?.count ?? 30
        let percentage = Float(activeDays) / Float(daysInMonth) * 100
        return min(100, Int(percentage))
    }
    
    /// Refresh data (pull-to-refresh)
    func refreshData() {
        loadDashboardData()
    }
    
    // MARK: - User Actions (Events)
    
    /// Handle user events
    func onEvent(_ event: HomeEvent) {
        switch event {
        case .loadDashboardData:
            loadDashboardData()
            
        case .refreshData:
            refreshData()
            
        case .startStudy:
            handleStartStudy()
            
        case .navigateToPackageSelection:
            handleNavigateToPackageSelection()
            
        case .navigateToAIAssistant:
            handleNavigateToAIAssistant()
            
        case .showAddWordDialog:
            handleShowAddWordDialog()
            
        case .dismissPremiumPush:
            dismissPremiumPush()
            
        case .premiumPurchaseSuccess:
            onPremiumPurchaseSuccess()
        }
    }
    
    // MARK: - Navigation Handlers
    
    /// ✅ FIXED: Handle start study action with navigation
    private func handleStartStudy() {
        soundManager.playClickSound()
        
        let selectedWordsCount = userDefaults.loadSelectedWords().count
        
        if selectedWordsCount > 0 {
            print("✅ Navigating to study with \(selectedWordsCount) words")
            // ✅ Trigger navigation via published property
            shouldNavigateToStudy = true
        } else {
            print("⚠️ No words selected - navigating to package selection")
            shouldNavigateToPackageSelection = true
        }
    }
    
    /// ✅ Handle navigate to package selection
    private func handleNavigateToPackageSelection() {
        soundManager.playClickSound()
        print("📦 Navigating to package selection")
        shouldNavigateToPackageSelection = true
    }
    
    /// ✅ Handle navigate to AI assistant
    private func handleNavigateToAIAssistant() {
        soundManager.playClickSound()
        print("🤖 Navigating to AI assistant")
        shouldNavigateToAIAssistant = true
    }
    
    /// ✅ NEW: Handle show add word dialog
    private func handleShowAddWordDialog() {
        soundManager.playClickSound()
        print("➕ Showing add word dialog")
        shouldShowAddWordDialog = true
    }
    
    // MARK: - Other Actions
    
    /// Track app launch (for statistics)
    private func trackAppLaunch() {
        // TODO: Implement app launch tracking
        print("📱 App launched")
    }
    
    /// Check premium status
    private func checkPremiumStatus() {
        // TODO: Implement premium check
        uiState.isPremium = false
    }
    
    /// Dismiss premium push
    private func dismissPremiumPush() {
        uiState.showPremiumPush = false
    }
    
    /// Handle premium purchase success
    private func onPremiumPurchaseSuccess() {
        uiState.isPremium = true
        uiState.showPremiumPush = false
        print("🎉 Premium purchase successful!")
    }
    
    // MARK: - Stats Update
    
    /// Update stats after study session
    func updateAfterStudy(wordsLearned: Int) {
        uiState.dailyGoalProgress.currentWords += wordsLearned
        
        // Update in UserDefaults
        userDefaults.updateStats(wordsStudiedToday: wordsLearned)
        
        // Refresh to get latest data
        refreshData()
    }
}
