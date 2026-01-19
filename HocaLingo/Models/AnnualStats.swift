//
//  AnnualStats.swift
//  HocaLingo
//
//  Yearly statistics model - tracks annual user activity
//  Location: HocaLingo/Models/AnnualStats.swift
//

import Foundation

// MARK: - Annual Stats Model
/// Yearly statistics for profile display
/// Tracks: active days, study hours, and skipped words in the current year
/// Location: HocaLingo/Models/AnnualStats.swift
struct AnnualStats: Codable {
    /// Number of days user was active this year (had any study session)
    var activeDaysThisYear: Int
    
    /// Total study hours this year (rounded, no minutes)
    var studyHoursThisYear: Int
    
    /// Total number of words user swiped left (skipped) in word selection
    var wordsSkippedThisYear: Int
    
    // MARK: - Initialization
    
    init(
        activeDaysThisYear: Int = 0,
        studyHoursThisYear: Int = 0,
        wordsSkippedThisYear: Int = 0
    ) {
        self.activeDaysThisYear = activeDaysThisYear
        self.studyHoursThisYear = studyHoursThisYear
        self.wordsSkippedThisYear = wordsSkippedThisYear
    }
    
    // MARK: - Default
    
    /// Empty stats (for initial state)
    static let empty = AnnualStats()
    
    // MARK: - Display Helpers
    
    /// Format active days for display (e.g., "45 days")
    var activeDaysFormatted: String {
        return "\(activeDaysThisYear)"
    }
    
    /// Format study hours for display (e.g., "23 hours")
    var studyHoursFormatted: String {
        return "\(studyHoursThisYear)"
    }
    
    /// Format skipped words for display (e.g., "120 words")
    var wordsSkippedFormatted: String {
        return "\(wordsSkippedThisYear)"
    }
}
