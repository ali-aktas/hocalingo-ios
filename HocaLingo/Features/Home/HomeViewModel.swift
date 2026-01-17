//
//  HomeViewModel.swift
//  HocaLingo
//
//  Complete Home ViewModel - MATCHES Android HomeViewModel v2.1
//  Location: HocaLingo/Features/Home/HomeViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Home View Model
/// Business logic for home dashboard - production-grade with Android parity
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var uiState = HomeUiState()
    
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
            return "Good Morning! ☀️"
        case 12..<17:
            return "Good Afternoon! 🌤️"
        case 17..<22:
            return "Good Evening! 🌙"
        default:
            return "Good Night! ✨"
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
        
        // ✅ FIXED: Load today's ACTUAL graduation count (Android parity)
        let todayStats = userDefaults.getTodayDailyStats()
        
        // Update daily goal progress with ACTUAL graduations
        uiState.dailyGoalProgress = DailyGoalProgress(
            currentWords: todayStats.wordsGraduated, // ✅ Real graduations, not simple count
            targetWords: 20 // TODO: Load from settings
        )
        
        // Load monthly stats
        loadMonthlyStats()
        
        // Get user name (if available)
        uiState.userName = userDefaults.loadUserName() ?? "Student"
        
        // Clear old monthly data if new month
        userDefaults.clearMonthlyStatsIfNeeded()
        
        // Reset weekly stats if new week
        userDefaults.resetWeeklyStatsIfNeeded()
        
        uiState.isLoading = false
        
        print("📊 Dashboard loaded:")
        print("   - Streak: \(uiState.streakDays) days")
        print("   - Today graduations: \(uiState.dailyGoalProgress.currentWords)/\(uiState.dailyGoalProgress.targetWords)")
        print("   - Total cards studied: \(todayStats.wordsStudied)")
        print("   - Total learned: \(stats.wordsLearned)")
    }
    
    /// Load monthly study statistics
    private func loadMonthlyStats() {
        // TODO: Implement monthly stats tracking
        // For now, use simple data from UserDefaults
        let stats = userDefaults.loadUserStats()
        
        uiState.monthlyStats = MonthlyStats(
            studiedDays: [], // Will be populated in Day 8-11
            totalDaysStudied: stats.currentStreak,
            currentMonthWords: stats.wordsStudiedToday
        )
    }
    
    /// Refresh data (call after returning from study)
    func refreshData() {
        loadDashboardData()
    }
    
    // MARK: - Premium Management
    
    /// Check premium status
    private func checkPremiumStatus() {
        // TODO: Implement premium check with RevenueCat
        uiState.isPremium = false
    }
    
    /// Show premium push notification
    func showPremiumPush() {
        uiState.showPremiumPush = true
    }
    
    /// Dismiss premium push
    func dismissPremiumPush() {
        uiState.showPremiumPush = false
    }
    
    /// Handle successful premium purchase
    func onPremiumPurchaseSuccess() {
        uiState.isPremium = true
        uiState.showPremiumPush = false
    }
    
    // MARK: - Streak Tracking
    
    /// Track app launch for streak calculation
    private func trackAppLaunch() {
        let lastLaunchDate = userDefaults.loadLastLaunchDate()
        let today = Date()
        
        // Check if this is first launch today
        if !Calendar.current.isDateInToday(lastLaunchDate) {
            // Save today as last launch
            userDefaults.saveLastLaunchDate(today)
            
            // Update streak
            updateStreak(lastLaunchDate: lastLaunchDate, today: today)
        }
        
        print("📅 App launched - Streak tracking updated")
    }
    
    /// Update streak based on launch dates
    private func updateStreak(lastLaunchDate: Date, today: Date) {
        let calendar = Calendar.current
        
        // Check if last launch was yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastLaunchDate, inSameDayAs: yesterday) {
            // Continue streak
            var stats = userDefaults.loadUserStats()
            stats.currentStreak += 1
            userDefaults.saveUserStats(stats)
            
            print("🔥 Streak continued: \(stats.currentStreak) days")
        } else if calendar.isDate(lastLaunchDate, inSameDayAs: today) {
            // Same day, do nothing
            print("✅ Same day launch")
        } else {
            // Streak broken, reset to 1
            var stats = userDefaults.loadUserStats()
            stats.currentStreak = 1
            userDefaults.saveUserStats(stats)
            
            print("💔 Streak reset to 1")
        }
    }
    
    // MARK: - Event Handling
    
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
            
        case .dismissPremiumPush:
            dismissPremiumPush()
            
        case .premiumPurchaseSuccess:
            onPremiumPurchaseSuccess()
        }
    }
    
    // MARK: - Actions
    
    /// Handle start study action
    private func handleStartStudy() {
        soundManager.playClickSound()  // ✅ FIXED: Direct function call
        
        let selectedWordsCount = userDefaults.loadSelectedWords().count
        
        if selectedWordsCount > 0 {
            print("✅ Starting study with \(selectedWordsCount) words")
            // Navigation handled by parent view
        } else {
            print("⚠️ No words selected")
            // Show message or navigate to package selection
        }
    }
    
    /// Handle navigate to package selection
    private func handleNavigateToPackageSelection() {
        soundManager.playClickSound()  // ✅ FIXED: Direct function call
        print("📦 Navigating to package selection")
        // Navigation handled by parent view
    }
    
    /// Handle navigate to AI assistant
    private func handleNavigateToAIAssistant() {
        soundManager.playClickSound()  // ✅ FIXED: Direct function call
        print("🤖 Navigating to AI assistant")
        // Navigation handled by parent view
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
