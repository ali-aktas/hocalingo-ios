//
//  WordSelector.swift
//  HocaLingo
//
//  Core/Utils/WordSelector.swift
//  ✅ UPDATED: Learning phase included, exact count (20 or 40)
//  Location: HocaLingo/Core/Utils/WordSelector.swift
//

import Foundation

/// Word selection service
/// Selects appropriate words from user's vocabulary for story generation
class WordSelector {
    
    /// Maximum progress interval for word selection (21 days)
    /// Only words reviewed within last 21 days are eligible
    /// ✅ Learning phase is NOW included (review not required)
    private let maxProgressDays: Float = 21.0
    
    /// UserDefaults manager for loading progress
    private let userDefaults = UserDefaultsManager.shared
    
    /// Select words for story generation
    /// ✅ UPDATED: Exact count (20 or 40), no random range
    /// - Parameters:
    ///   - allWords: All words from user's deck
    ///   - length: Desired story length (determines EXACT word count)
    ///   - direction: Study direction to filter progress
    /// - Returns: Selected words with meanings (EXACTLY 20 or 40 words)
    /// - Throws: AIStoryError.insufficientWords if not enough eligible words
    func selectWords(
        from allWords: [Word],
        for length: StoryLength,
        direction: StudyDirection = .enToTr
    ) throws -> [WordWithMeaning] {
        
        // Step 1: Filter eligible words
        // ✅ NEW: Learning phase is NOW included
        let eligibleWords = filterEligibleWords(from: allWords, direction: direction)
        
        // Step 2: Validate minimum requirement
        let exactCount = length.exactDeckWords
        guard eligibleWords.count >= exactCount else {
            throw AIStoryError.insufficientWords(
                required: exactCount,
                available: eligibleWords.count
            )
        }
        
        // Step 3: Select EXACTLY the required count
        // ✅ NO random range - always 20 or 40
        let selectedWords = eligibleWords.shuffled().prefix(exactCount)
        
        // Step 4: Convert to WordWithMeaning
        return selectedWords.map { word in
            WordWithMeaning(
                id: word.id,
                english: word.english,
                turkish: word.turkish
            )
        }
    }
    
    // MARK: - Private Helpers
    
    /// Filter eligible words
    /// ✅ UPDATED: Learning phase NOW included!
    /// Rules:
    /// 1. Word must be selected (isSelected = true)
    /// 2. Word must have progress (exists in UserDefaults)
    /// 3. Interval must be < 21 days
    /// 4. ✅ Learning phase is OK (removed learningPhase check)
    private func filterEligibleWords(
        from words: [Word],
        direction: StudyDirection
    ) -> [Word] {
        return words.filter { word in
            // Load progress for this word
            guard let progress = userDefaults.loadProgress(for: word.id, direction: direction) else {
                return false
            }
            
            // ✅ UPDATED: Only check isSelected and intervalDays
            // Learning phase is NOW acceptable!
            return progress.isSelected && progress.intervalDays < maxProgressDays
        }
    }
    
    /// Calculate word difficulty score (for future advanced selection)
    /// Lower score = easier word, Higher score = harder word
    private func difficultyScore(for word: Word, direction: StudyDirection) -> Int {
        guard let progress = userDefaults.loadProgress(for: word.id, direction: direction) else {
            return 0
        }
        
        // Consider: interval, ease factor, hard presses
        let intervalScore = Int(progress.intervalDays)
        let easeScore = Int((1.0 - progress.easeFactor) * 100)
        let hardScore = (progress.hardPresses ?? 0) * 10
        
        return intervalScore + easeScore + hardScore
    }
}
