//
//  UserStats.swift
//  HocaLingo
//
//  Updated on 15.01.2026.
//

import Foundation

// MARK: - User Stats Model
/// User statistics for profile display with persistence support
/// Location: HocaLingo/Models/UserStats.swift
struct UserStats: Codable {
    var totalWordsStudied: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalStudyTime: Int // in minutes
    var wordsLearned: Int
    var wordsReviewing: Int
    
    // Additional stats for better UX
    var totalWordsSelected: Int
    var wordsStudiedToday: Int
    var masteredWordsCount: Int
    var studyTimeThisWeek: Int // minutes
    var averageAccuracy: Float // 0.0 - 1.0
    
    // MARK: - Initialization
    init(
        totalWordsStudied: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalStudyTime: Int = 0,
        wordsLearned: Int = 0,
        wordsReviewing: Int = 0,
        totalWordsSelected: Int = 0,
        wordsStudiedToday: Int = 0,
        masteredWordsCount: Int = 0,
        studyTimeThisWeek: Int = 0,
        averageAccuracy: Float = 0.0
    ) {
        self.totalWordsStudied = totalWordsStudied
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalStudyTime = totalStudyTime
        self.wordsLearned = wordsLearned
        self.wordsReviewing = wordsReviewing
        self.totalWordsSelected = totalWordsSelected
        self.wordsStudiedToday = wordsStudiedToday
        self.masteredWordsCount = masteredWordsCount
        self.studyTimeThisWeek = studyTimeThisWeek
        self.averageAccuracy = averageAccuracy
    }
    
    /// Default empty stats
    static let empty = UserStats()
}
