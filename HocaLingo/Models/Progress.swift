//
//  Progress.swift
//  HocaLingo
//
//  Models package - User progress tracking
//

import Foundation

// MARK: - Progress Model
/// Tracks user's learning progress for each word
/// Matches Android's spaced repetition progress structure
struct Progress: Codable, Identifiable {
    let id: String // wordId + direction (e.g., "1000_en_tr")
    let wordId: Int
    let direction: StudyDirection // en->tr or tr->en
    
    // Spaced Repetition data
    var learningPhase: LearningPhase
    var repetitions: Int
    var easeFactor: Double
    var interval: Int // days
    var nextReviewDate: Date
    var lastReviewDate: Date?
    
    // Performance tracking
    var totalReviews: Int
    var correctCount: Int
    var incorrectCount: Int
    
    // Timestamps
    let createdAt: Date
    var updatedAt: Date
}

// MARK: - Study Direction
enum StudyDirection: String, Codable {
    case enToTr = "en_tr"
    case trToEn = "tr_en"
}

// MARK: - Learning Phase
enum LearningPhase: String, Codable {
    case learning = "LEARNING"    // New words
    case review = "REVIEW"        // Graduated words
    case relearning = "RELEARNING" // Failed reviews
}
