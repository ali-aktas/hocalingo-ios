//
//  SpacedRepetition.swift
//  HocaLingo
//
//  Core/Utils - Spaced Repetition Algorithm (SM-2)
//  ✅ PORT: SpacedRepetitionAlgorithm.kt → SpacedRepetition.swift
//

import Foundation

/// ✅ OPTIMIZED SM-2 Spaced Repetition Algorithm - VERSION 3
///
/// V3 MAJOR CHANGES:
/// 1. ✅ successfulReviews now Float (partial success tracking)
/// 2. ✅ MEDIUM = 0.5 points (graduation requires 3 points = 3 EASY or 6 MEDIUM)
/// 3. ✅ EASY = 1.0 point (full success)
/// 4. ✅ Review HARD: Reset to learning phase (start over)
///
/// Previous improvements:
/// - Learning phase = Same-day review scheduling
/// - Graduation = Real learning (minimum 3 successful reviews)
/// - Session position = Same-day ordering
/// - Review MEDIUM: Adaptive multiplier (interval-based)
class SpacedRepetition {
    
    // MARK: - Quality Scores
    static let QUALITY_HARD = 1      // "Hard" - Didn't remember, show again
    static let QUALITY_MEDIUM = 2    // "Medium" - Remembered but struggled
    static let QUALITY_EASY = 3      // "Easy" - Remembered easily
    
    // MARK: - Learning Phase Constants
    private static let HARD_POSITION_INCREMENT = 1      // Move to front
    private static let MEDIUM_POSITION_INCREMENT = 5    // Move to middle
    private static let EASY_POSITION_INCREMENT = 10     // Move to end
    
    // Graduation thresholds (real learning criteria)
    private static let MIN_SUCCESSFUL_REVIEWS: Float = 3.0  // At least 3.0 points
    private static let MAX_HARD_PRESSES_TO_GRADUATE = 1     // Max 1 HARD press
    
    // MARK: - Review Phase Constants
    // Initial interval after graduation
    private static let GRADUATION_INTERVAL_DAYS: Float = 1.0  // 1 day (first review)
    
    // Standard review intervals
    private static let SECOND_REVIEW_INTERVAL_DAYS: Float = 3.0   // 2nd review: 3 days
    private static let THIRD_REVIEW_INTERVAL_DAYS: Float = 7.0    // 3rd review: 7 days
    
    // Ease factor bounds
    private static let MIN_EASE_FACTOR: Float = 1.3
    private static let MAX_EASE_FACTOR: Float = 2.5
    private static let DEFAULT_EASE_FACTOR: Float = 2.5
    
    // Max interval cap
    private static let MAX_INTERVAL_DAYS: Float = 365.0  // 1 year
    
    // MARK: - Main Algorithm
    
    /// ✅ V3 OPTIMIZED: Calculate next review with partial success tracking
    static func calculateNextReview(
        currentProgress: Progress,
        quality: Int,
        currentSessionMaxPosition: Int = 100
    ) -> Progress {
        let currentTime = Date()
        let todayEnd = getTodayEndTime(currentTime)
        
        print("🔥 SM-2 V3: quality=\(quality), reps=\(currentProgress.repetitions), learningPhase=\(currentProgress.learningPhase), hardPresses=\(currentProgress.hardPresses ?? 0), successfulReviews=\(currentProgress.successfulReviews ?? 0)")
        
        // Route to appropriate phase handler
        if currentProgress.learningPhase {
            return handleLearningPhase(
                currentProgress: currentProgress,
                quality: quality,
                currentSessionMaxPosition: currentSessionMaxPosition,
                currentTime: currentTime,
                todayEnd: todayEnd
            )
        } else {
            return handleReviewPhase(
                currentProgress: currentProgress,
                quality: quality,
                currentTime: currentTime
            )
        }
    }
    
    // MARK: - Learning Phase
    
    /// ✅ V3 Learning Phase: MEDIUM = 0.5 points, EASY = 1.0 point
    ///
    /// HARD behavior:
    /// - Reset successful reviews to 0
    /// - Increment hard presses counter
    /// - Show again soon (front of queue)
    ///
    /// MEDIUM behavior:
    /// - Add 0.5 points to successful reviews
    /// - Graduate if >= 3.0 points AND hard presses <= 1
    ///
    /// EASY behavior:
    /// - Add 1.0 point to successful reviews
    /// - Graduate if >= 3.0 points AND hard presses <= 1
    private static func handleLearningPhase(
        currentProgress: Progress,
        quality: Int,
        currentSessionMaxPosition: Int,
        currentTime: Date,
        todayEnd: Date
    ) -> Progress {
        
        switch quality {
        case QUALITY_HARD:
            print("🔴 LEARNING HARD: Reset to 0, position = front")
            
            let newReps = currentProgress.repetitions + 1
            
            var updated = currentProgress
            updated.repetitions = newReps
            updated.intervalDays = 0
            updated.easeFactor = max(MIN_EASE_FACTOR, currentProgress.easeFactor - 0.2)
            updated.nextReviewAt = currentTime.addingTimeInterval(5 * 60) // 5 minutes
            updated.lastReviewAt = currentTime
            updated.learningPhase = true
            updated.sessionPosition = currentSessionMaxPosition + HARD_POSITION_INCREMENT
            updated.hardPresses = (currentProgress.hardPresses ?? 0) + 1
            updated.successfulReviews = 0
            updated.updatedAt = currentTime
            
            return updated
            
        case QUALITY_MEDIUM:
            let newSuccessful = (currentProgress.successfulReviews ?? 0) + 0.5  // ✅ Half point
            let newReps = currentProgress.repetitions + 1
            let hardPresses = currentProgress.hardPresses ?? 0
            
            // ✅ Check graduation
            if shouldGraduate(successfulReviews: newSuccessful, hardPresses: hardPresses) {
                print("🎓 GRADUATING (MEDIUM): \(newSuccessful) points, \(hardPresses) hard")
                return graduateToReview(
                    currentProgress: currentProgress,
                    newReps: newReps,
                    currentTime: currentTime
                )
            } else {
                print("🟡 LEARNING MEDIUM: Position = middle, successful = \(newSuccessful) points")
                
                var updated = currentProgress
                updated.repetitions = newReps
                updated.intervalDays = 0
                updated.easeFactor = min(MAX_EASE_FACTOR, currentProgress.easeFactor + 0.05)
                updated.nextReviewAt = currentTime.addingTimeInterval(10 * 60) // 10 minutes
                updated.lastReviewAt = currentTime
                updated.learningPhase = true
                updated.sessionPosition = currentSessionMaxPosition + MEDIUM_POSITION_INCREMENT
                updated.successfulReviews = newSuccessful  // ✅ Half point added
                updated.updatedAt = currentTime
                
                return updated
            }
            
        case QUALITY_EASY:
            let newSuccessful = (currentProgress.successfulReviews ?? 0) + 1.0  // ✅ Full point
            let newReps = currentProgress.repetitions + 1
            let hardPresses = currentProgress.hardPresses ?? 0
            
            // ✅ Check graduation
            if shouldGraduate(successfulReviews: newSuccessful, hardPresses: hardPresses) {
                print("🎓 GRADUATING (EASY): \(newSuccessful) points, \(hardPresses) hard")
                return graduateToReview(
                    currentProgress: currentProgress,
                    newReps: newReps,
                    currentTime: currentTime
                )
            } else {
                print("🟢 LEARNING EASY: Position = end, successful = \(newSuccessful) points")
                
                var updated = currentProgress
                updated.repetitions = newReps
                updated.intervalDays = 0
                updated.easeFactor = min(MAX_EASE_FACTOR, currentProgress.easeFactor + 0.1)
                updated.nextReviewAt = currentTime.addingTimeInterval(60 * 60) // 1 hour
                updated.lastReviewAt = currentTime
                updated.learningPhase = true
                updated.sessionPosition = currentSessionMaxPosition + EASY_POSITION_INCREMENT
                updated.successfulReviews = newSuccessful  // ✅ Full point added
                updated.updatedAt = currentTime
                
                return updated
            }
            
        default:
            return currentProgress
        }
    }
    
    // MARK: - Review Phase
    
    /// ✅ V3 Review Phase: HARD resets to learning phase
    ///
    /// HARD behavior:
    /// - Back to learning phase (start over)
    /// - User didn't remember the word
    private static func handleReviewPhase(
        currentProgress: Progress,
        quality: Int,
        currentTime: Date
    ) -> Progress {
        
        switch quality {
        case QUALITY_HARD:
            print("🔴 REVIEW HARD: Back to learning phase")
            
            // ✅ Failed review → Back to learning phase
            var updated = currentProgress
            updated.repetitions = 1
            updated.intervalDays = GRADUATION_INTERVAL_DAYS
            updated.easeFactor = max(MIN_EASE_FACTOR, currentProgress.easeFactor - 0.2)
            updated.nextReviewAt = currentTime.addingTimeInterval(TimeInterval(GRADUATION_INTERVAL_DAYS * 24 * 60 * 60))
            updated.lastReviewAt = currentTime
            updated.learningPhase = false
            updated.sessionPosition = nil
            updated.hardPresses = (currentProgress.hardPresses ?? 0) + 1
            updated.successfulReviews = 0
            updated.updatedAt = currentTime
            
            return updated
            
        case QUALITY_MEDIUM:
            print("🟡 REVIEW MEDIUM: Adaptive progression/reduction")
            
            let newReps = currentProgress.repetitions + 1
            let baseInterval = max(1.0, currentProgress.intervalDays)
            let newEaseFactor = updateEaseFactor(currentEF: currentProgress.easeFactor, quality: 4)
            
            // ✅ ADAPTIVE MULTIPLIER: Dynamic behavior based on interval
            let mediumMultiplier: Float
            switch baseInterval {
            case ...3.0:
                mediumMultiplier = 1.5  // 0-3 days: Gentle progression
            case ...7.0:
                mediumMultiplier = 1.2  // 4-7 days: Light progression
            case ...21.0:
                mediumMultiplier = 0.85 // 8-21 days: Light reduction
            default:
                mediumMultiplier = 0.5  // 21+ days: Significant reduction
            }
            
            let calculatedInterval = baseInterval * mediumMultiplier
            let finalInterval = min(calculatedInterval, MAX_INTERVAL_DAYS)
            
            print("🔧 MEDIUM: baseInterval=\(baseInterval)d, multiplier=\(mediumMultiplier), EF=\(newEaseFactor), finalInterval=\(finalInterval)d")
            
            var updated = currentProgress
            updated.repetitions = newReps
            updated.intervalDays = finalInterval
            updated.easeFactor = newEaseFactor
            updated.nextReviewAt = currentTime.addingTimeInterval(TimeInterval(finalInterval * 24 * 60 * 60))
            updated.lastReviewAt = currentTime
            updated.learningPhase = false
            updated.sessionPosition = nil
            updated.updatedAt = currentTime
            
            return updated
            
        case QUALITY_EASY:
            print("🟢 REVIEW EASY: Strong progression")
            
            let newReps = currentProgress.repetitions + 1
            let newEaseFactor = updateEaseFactor(currentEF: currentProgress.easeFactor, quality: 5)
            
            // ✅ Progressive interval calculation
            let calculatedInterval: Float
            switch newReps {
            case 1:
                calculatedInterval = GRADUATION_INTERVAL_DAYS     // 1 day
            case 2:
                calculatedInterval = SECOND_REVIEW_INTERVAL_DAYS  // 3 days
            case 3:
                calculatedInterval = THIRD_REVIEW_INTERVAL_DAYS   // 7 days
            default:
                let baseInterval = max(1.0, currentProgress.intervalDays)
                calculatedInterval = baseInterval * newEaseFactor
            }
            
            let finalInterval = min(calculatedInterval, MAX_INTERVAL_DAYS)
            
            var updated = currentProgress
            updated.repetitions = newReps
            updated.intervalDays = finalInterval
            updated.easeFactor = newEaseFactor
            updated.nextReviewAt = currentTime.addingTimeInterval(TimeInterval(finalInterval * 24 * 60 * 60))
            updated.lastReviewAt = currentTime
            updated.learningPhase = false
            updated.sessionPosition = nil
            updated.updatedAt = currentTime
            
            return updated
            
        default:
            return currentProgress
        }
    }
    
    // MARK: - Helper Functions
    
    /// ✅ Get today's end time (23:59:59.999)
    private static func getTodayEndTime(_ currentTime: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: currentTime)
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.nanosecond = 999_000_000
        return calendar.date(from: components) ?? currentTime
    }
    
    /// ✅ V3 Graduation criteria: 3.0 points required
    private static func shouldGraduate(successfulReviews: Float, hardPresses: Int) -> Bool {
        return successfulReviews >= MIN_SUCCESSFUL_REVIEWS  // ✅ Float comparison: >= 3.0
    }
    
    /// ✅ Graduate to Review Phase
    private static func graduateToReview(
        currentProgress: Progress,
        newReps: Int,
        currentTime: Date
    ) -> Progress {
        var updated = currentProgress
        updated.repetitions = newReps
        updated.intervalDays = GRADUATION_INTERVAL_DAYS
        updated.easeFactor = min(MAX_EASE_FACTOR, currentProgress.easeFactor + 0.15)
        updated.nextReviewAt = currentTime.addingTimeInterval(TimeInterval(GRADUATION_INTERVAL_DAYS * 24 * 60 * 60))
        updated.lastReviewAt = currentTime
        updated.learningPhase = false  // ✅ GRADUATE
        updated.sessionPosition = nil
        updated.updatedAt = currentTime
        
        return updated
    }
    
    /// ✅ SM-2 Ease Factor update formula
    private static func updateEaseFactor(currentEF: Float, quality: Int) -> Float {
        let newEF = currentEF + (0.1 - Float(5 - quality) * (0.08 + Float(5 - quality) * 0.02))
        return max(MIN_EASE_FACTOR, min(newEF, MAX_EASE_FACTOR))
    }
    
    /// ✅ Get human-readable time until review
    static func getTimeUntilReview(nextReviewAt: Date) -> String {
        let currentTime = Date()
        let timeDifference = nextReviewAt.timeIntervalSince(currentTime)
        
        if timeDifference <= 0 {
            return "Şimdi"
        }
        
        let minutes = Int(timeDifference / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        switch (minutes, hours, days) {
        case (0..<5, _, _):
            return "Hemen tekrar"          // 0-5 min
        case (5..<30, _, _):
            return "Birazdan"              // 5-30 min
        case (_, 0..<2, _):
            return "Sonra"                 // 30min-2hr
        case (_, 2..<12, _):
            return "Bugün"                 // 2-12 hours
        case (_, 12..<24, _):
            return "Bu gün"                // 12-24 hours
        case (_, _, 1):
            return "Yarın"                 // Tomorrow
        case (_, _, 2):
            return "2 gün"                 // 2 days
        case (_, _, 3):
            return "3 gün"                 // 3 days
        case (_, _, let d) where d < 7:
            return "\(d) gün"              // 3-7 days
        case (_, _, let d) where d < 14:
            return "1 hafta"               // 1 week
        case (_, _, let d) where d < 21:
            return "2 hafta"               // 2 weeks
        case (_, _, let d) where d < 30:
            return "3 hafta"               // 3 weeks
        case (_, _, let d) where d < 60:
            return "1 ay"                  // 1 month
        case (_, _, let d) where d < 180:
            return "\(d / 30) ay"          // months
        default:
            return "6+ ay"                 // 6+ months
        }
    }
}
