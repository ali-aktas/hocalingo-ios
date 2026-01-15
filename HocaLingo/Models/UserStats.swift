//
//  UserStats.swift
//  HocaLingo
//
//  Models package - User statistics
//

import Foundation

// MARK: - User Stats Model
/// Daily statistics and streak tracking
struct UserStats: Codable {
    var dailyStudyCount: Int
    var dailyGoal: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalWordsLearned: Int
    var totalReviews: Int
    var lastStudyDate: Date?
    
    // Today's progress
    var todayCorrect: Int
    var todayIncorrect: Int
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    // Computed property
    var isGoalReached: Bool {
        dailyStudyCount >= dailyGoal
    }
    
    var studyProgress: Double {
        min(Double(dailyStudyCount) / Double(dailyGoal), 1.0)
    }
}
