//
//  HomeUiState.swift
//  HocaLingo
//
//  ✅ FIXED: Localized formattedStudyTime (8m → 8dk in Turkish)
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

// MARK: - Monthly Stats (ANDROID PARITY)
struct MonthlyStats {
    var studyTimeToday: Int = 0      // Bugünün dakikası
    var studyTimeThisMonth: Int = 0  // Ayın toplam dakikası
    var activeDaysThisMonth: Int = 0
    var disciplineScore: Int = 0
    
    /// ✅ "8 min / 2h 56m" veya "8dk / 1s 27dk" formatı
    var formattedStudyTime: String {
        let minUnit = NSLocalizedString("unit_minute_short", comment: "")
        let hourUnit = NSLocalizedString("unit_hour_short", comment: "")
        
        func formatTime(_ totalMin: Int) -> String {
            let h = totalMin / 60
            let m = totalMin % 60
            if h > 0 {
                return "\(h)\(hourUnit) \(m)\(minUnit)"
            }
            return "\(m)\(minUnit)"
        }
        
        return "\(formatTime(studyTimeThisMonth))"
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
    case showAddWordDialog
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
