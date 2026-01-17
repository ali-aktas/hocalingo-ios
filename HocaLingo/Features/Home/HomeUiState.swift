//
//  HomeUiState.swift
//  HocaLingo
//
//  ✅ UPDATED: Monthly stats added - matches Android HomeUiState v2.0
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
    var monthlyStats: MonthlyStats = MonthlyStats() // ✅ UPDATED: Changed from monthlyStats
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

// MARK: - Monthly Stats (ANDROID PARITY)
/// ✅ NEW: Monthly study statistics matching Android exactly
struct MonthlyStats {
    var activeDaysThisMonth: Int = 0
    var studyTimeThisMonth: Int = 0  // Total minutes
    var disciplineScore: Int = 0      // 0-100
    
    /// Format study time as "Xh Ym" or "Xm"
    var formattedStudyTime: String {
        let hours = studyTimeThisMonth / 60
        let minutes = studyTimeThisMonth % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
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
    case showAddWordDialog           // ✅ NEW
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
