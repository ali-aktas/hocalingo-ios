//
//  Progress.swift
//  HocaLingo
//
//  Models package - User progress tracking
//  ✅ FIXED: Removed duplicate StudyDirection enum
//

import Foundation

// MARK: - Progress Model
/// Tracks user's learning progress for each word
/// ✅ Matches Android's WordProgressEntity structure exactly
struct Progress: Codable, Identifiable {
    // MARK: - Identity
    var id: String { "\(wordId)_\(direction.rawValue)" } // Auto-generated ID
    let wordId: Int
    let direction: StudyDirection // en_tr or tr_en (uses existing enum!)
    
    // MARK: - Spaced Repetition Core Data (SM-2 Algorithm)
    var repetitions: Int                    // Number of successful reviews
    var intervalDays: Float                 // Days until next review (can be fractional)
    var easeFactor: Float                   // SM-2 ease factor (1.3 - 2.5)
    var nextReviewAt: Date                  // Next review timestamp
    var lastReviewAt: Date?                 // Last review timestamp (nullable)
    
    // MARK: - Learning Phase Data
    var learningPhase: Bool                 // true = Learning, false = Review phase
    var sessionPosition: Int?               // Same-day sorting position (nullable)
    var successfulReviews: Float?           // V3: Partial success points (0.5 for MEDIUM, 1.0 for EASY)
    var hardPresses: Int?                   // Count of HARD button presses (graduation criteria)
    
    // MARK: - Status Flags
    var isSelected: Bool                    // Is this word selected for study?
    var isMastered: Bool                    // Has this word been mastered? (21+ days interval)
    
    // MARK: - Timestamps
    let createdAt: Date
    var updatedAt: Date
    
    // MARK: - CodingKeys (exclude computed 'id' property)
    enum CodingKeys: String, CodingKey {
        case wordId, direction
        case repetitions, intervalDays, easeFactor
        case nextReviewAt, lastReviewAt
        case learningPhase, sessionPosition
        case successfulReviews, hardPresses
        case isSelected, isMastered
        case createdAt, updatedAt
        // Note: 'id' is not included - it's computed
    }
    
    // MARK: - Initializer
    init(
        wordId: Int,
        direction: StudyDirection,
        repetitions: Int = 0,
        intervalDays: Float = 0,
        easeFactor: Float = 2.5,
        nextReviewAt: Date = Date(),
        lastReviewAt: Date? = nil,
        learningPhase: Bool = true,
        sessionPosition: Int? = nil,
        successfulReviews: Float? = 0,
        hardPresses: Int? = 0,
        isSelected: Bool = true,
        isMastered: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.wordId = wordId
        self.direction = direction
        self.repetitions = repetitions
        self.intervalDays = intervalDays
        self.easeFactor = easeFactor
        self.nextReviewAt = nextReviewAt
        self.lastReviewAt = lastReviewAt
        self.learningPhase = learningPhase
        self.sessionPosition = sessionPosition
        self.successfulReviews = successfulReviews
        self.hardPresses = hardPresses
        self.isSelected = isSelected
        self.isMastered = isMastered
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
