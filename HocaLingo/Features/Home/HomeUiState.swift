//
//  HomeUiState.swift
//  HocaLingo
//
//  Home screen state management - MATCHES Android HomeUiState
//  Location: HocaLingo/Features/Home/HomeUiState.swift
//

import Foundation

// MARK: - Home UI State
/// Complete UI state for Home dashboard - matches Android v2.0
struct HomeUiState {
    var isLoading: Bool = false
    var userName: String = ""
    var streakDays: Int = 0
    var dailyGoalProgress: DailyGoalProgress = DailyGoalProgress()
    var monthlyStats: MonthlyStats = MonthlyStats()
    var error: String? = nil
    var showPremiumPush: Bool = false
    var isPremium: Bool = false
}

// MARK: - Daily Goal Progress
/// Tracks progress toward daily word learning goal
struct DailyGoalProgress {
    var currentWords: Int = 0
    var targetWords: Int = 20
    
    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard targetWords > 0 else { return 0.0 }
        return min(Double(currentWords) / Double(targetWords), 1.0)
    }
    
    /// Whether goal is completed
    var isCompleted: Bool {
        return currentWords >= targetWords
    }
    
    /// Remaining words to reach goal
    var remainingWords: Int {
        return max(0, targetWords - currentWords)
    }
}

// MARK: - Monthly Stats
/// Monthly study statistics for calendar view
struct MonthlyStats {
    var studiedDays: [String] = [] // ISO date strings: "2025-01-15"
    var totalDaysStudied: Int = 0
    var currentMonthWords: Int = 0
    
    /// Check if a specific date was studied
    func wasStudied(date: Date) -> Bool {
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        return studiedDays.contains(String(dateString))
    }
}

// MARK: - Home Events
/// User actions from Home screen
enum HomeEvent {
    case loadDashboardData
    case refreshData
    case startStudy
    case navigateToPackageSelection
    case navigateToAIAssistant
    case dismissPremiumPush
    case premiumPurchaseSuccess
}

// MARK: - Home Effects
/// Side effects that trigger navigation or UI changes
enum HomeEffect {
    case navigateToStudy
    case navigateToPackageSelection
    case navigateToAIAssistant
    case showMessage(String)
    case showError(String)
}
