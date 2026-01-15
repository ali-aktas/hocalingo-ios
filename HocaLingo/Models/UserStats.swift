import Foundation

// MARK: - User Stats Model
/// User statistics for profile display
struct UserStats {
    let totalWordsSelected: Int
    let wordsStudiedToday: Int
    let masteredWordsCount: Int
    let currentStreak: Int
    let studyTimeThisWeek: Int // minutes
    let averageAccuracy: Float // 0.0 - 1.0
    
    /// Default empty stats
    static let empty = UserStats(
        totalWordsSelected: 0,
        wordsStudiedToday: 0,
        masteredWordsCount: 0,
        currentStreak: 0,
        studyTimeThisWeek: 0,
        averageAccuracy: 0.0
    )
    
    /// Dummy stats for testing
    static let dummy = UserStats(
        totalWordsSelected: 127,
        wordsStudiedToday: 15,
        masteredWordsCount: 43,
        currentStreak: 7,
        studyTimeThisWeek: 145,
        averageAccuracy: 0.87
    )
}
