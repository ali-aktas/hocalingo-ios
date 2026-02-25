//
//  Progress+Extensions.swift
//  HocaLingo
//
//  Progress model extensions - Mastered logic & Study priority (Android parity)
//  Location: HocaLingo/Models/Progress+Extensions.swift
//

import Foundation

// MARK: - Progress Extensions
extension Progress {
    
    // MARK: - Mastered Logic
    
    /// Check if word is mastered (21+ days interval in review phase)
    /// Matches Android's isMastered logic
    var isMastered: Bool {
        return !learningPhase && intervalDays >= 21.0
    }
    
    /// ✅ NEW: Check if word is learned (30+ days interval)
    /// This is for "Learned Words" stat on Home screen
    var isLearned: Bool {
        return !learningPhase && intervalDays >= 30.0
    }
    
    /// Get mastered status text for UI
    var masteredStatusText: String {
        if isMastered {
            return "Mastered ⭐"
        } else if !learningPhase {
            let daysUntilMastered = Int(ceil(21.0 - intervalDays))
            return "\(daysUntilMastered) days to master"
        } else {
            return "Learning"
        }
    }
    
    // MARK: - Study Priority
    
    /// Calculate study priority (higher = more urgent)
    /// Matches Android's getStudyPriority function
    static func calculateStudyPriority(_ progress: Progress, currentTime: Date = Date()) -> Int {
        let nextReview = progress.nextReviewAt
        let timeDiff = nextReview.timeIntervalSince(currentTime)
        
        // Learning phase = highest priority (same-day reviews)
        if progress.learningPhase {
            // Earlier session position = higher priority
            let sessionPriority = 10000 - (progress.sessionPosition ?? 0)
            return sessionPriority
        }
        
        // Review phase = priority based on how overdue
        if timeDiff <= 0 {
            // Overdue - more overdue = higher priority
            let overdueMinutes = Int(-timeDiff / 60)
            return 5000 + overdueMinutes
        } else {
            // Future review - closer = higher priority
            let futureMinutes = Int(timeDiff / 60)
            return max(0, 5000 - futureMinutes)
        }
    }
    
    /// Get study priority for this progress
    var studyPriority: Int {
        return Progress.calculateStudyPriority(self)
    }
    
    // MARK: - Time Until Review
    
    /// Get human-readable time until next review
    /// Matches Android's getTimeUntilReview function
    var timeUntilReview: String {
        let currentTime = Date()
        let timeDifference = nextReviewAt.timeIntervalSince(currentTime)
        
        if timeDifference <= 0 {
            return "Now"
        }
        
        let minutes = Int(timeDifference / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        switch (minutes, hours, days) {
        case (0..<5, _, _):
            return "Right now"
        case (5..<30, _, _):
            return "Soon"
        case (_, 0..<2, _):
            return "Later today"
        case (_, 2..<24, _):
            return "Today"
        case (_, _, 1):
            return "Tomorrow"
        case (_, _, 2..<7):
            return "\(days) days"
        case (_, _, 7..<30):
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        case (_, _, 30..<365):
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s")"
        default:
            return "1+ year"
        }
    }
    
    /// Get time until review for button display (shorter format)
    func getButtonTimeText(quality: Int) -> String {
        
        if learningPhase {
            // Learning phase times
            switch quality {
            case 1: // HARD
                return NSLocalizedString("time_5_min", comment: "")
            case 2: // MEDIUM
                return NSLocalizedString("time_later", comment: "")
            case 3: // EASY
                return NSLocalizedString("time_today", comment: "")
            default:
                return NSLocalizedString("time_soon", comment: "")
            }
        } else {
            // Review phase times (based on current interval)
            switch quality {
            case 1: // HARD - back to learning
                return NSLocalizedString("time_5_min", comment: "")
            case 2: // MEDIUM - reduced interval
                let reducedDays = Int(intervalDays * 0.8)
                if reducedDays == 0 {
                    return NSLocalizedString("time_today", comment: "")
                } else if reducedDays == 1 {
                    return NSLocalizedString("time_1_day", comment: "")
                } else if reducedDays < 7 {
                    return String(format: NSLocalizedString("time_n_days", comment: ""), reducedDays)
                } else {
                    let weeks = reducedDays / 7
                    return String(format: NSLocalizedString("time_n_wk", comment: ""), weeks)
                }
            case 3: // EASY - normal interval
                let nextDays = Int(intervalDays * easeFactor)
                if nextDays == 0 {
                    return NSLocalizedString("time_today", comment: "")
                } else if nextDays == 1 {
                    return NSLocalizedString("time_1_day", comment: "")
                } else if nextDays < 7 {
                    return String(format: NSLocalizedString("time_n_days", comment: ""), nextDays)
                } else if nextDays < 30 {
                    let weeks = nextDays / 7
                    return String(format: NSLocalizedString("time_n_wk", comment: ""), weeks)
                } else {
                    let months = nextDays / 30
                    return String(format: NSLocalizedString("time_n_mo", comment: ""), months)
                }
            default:
                return NSLocalizedString("time_soon", comment: "")
            }
        }
    }
    
    
    // MARK: - Phase Display
    
    /// Get display text for current phase
    var phaseDisplayText: String {
        if learningPhase {
            let points = successfulReviews ?? 0
            return "Learning (\(String(format: "%.1f", points))/3.0)"
        } else {
            return "Review"
        }
    }
    
    /// Get color for phase display
    var phaseColor: String {
        if learningPhase {
            return "FF9500" // Orange
        } else if isMastered {
            return "FFD700" // Gold
        } else {
            return "34C759" // Green
        }
    }
    
    // MARK: - Next Review Predictions
    
    /// Predict next review time for each quality (for button display)
    func predictNextReview(quality: Int) -> Date {
        // This is a simplified prediction
        // Actual calculation is done by SpacedRepetition.calculateNextReview
        
        let currentTime = Date()
        
        if learningPhase {
            switch quality {
            case 1: // HARD
                return currentTime.addingTimeInterval(5 * 60) // 5 minutes
            case 2: // MEDIUM
                return currentTime.addingTimeInterval(30 * 60) // 30 minutes
            case 3: // EASY
                return Calendar.current.date(byAdding: .hour, value: 2, to: currentTime) ?? currentTime
            default:
                return currentTime
            }
        } else {
            // Review phase
            switch quality {
            case 1: // HARD - back to learning
                return currentTime.addingTimeInterval(5 * 60)
            case 2: // MEDIUM - reduced interval
                let reducedDays = intervalDays * 0.8
                return currentTime.addingTimeInterval(Double(reducedDays) * 24 * 3600)
            case 3: // EASY - normal progression
                let nextInterval = intervalDays * easeFactor
                return currentTime.addingTimeInterval(Double(nextInterval) * 24 * 3600)
            default:
                return currentTime
            }
        }
    }
}
