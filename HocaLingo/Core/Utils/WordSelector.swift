//
//  WordSelector.swift
//  HocaLingo
//
//  Core/Utils/WordSelector.swift
//  Word selection logic for AI story generation
//  Filters words with progress < 21 days
//

import Foundation

/// Word selection service
/// Selects appropriate words from user's vocabulary for story generation
class WordSelector {
    
    /// Maximum progress interval for word selection (21 days)
    /// Only words reviewed within last 21 days are eligible
    private let maxProgressDays: Float = 21.0
    
    /// UserDefaults manager for loading progress
    private let userDefaults = UserDefaultsManager.shared
    
    /// Select words for story generation
    /// - Parameters:
    ///   - allWords: All words from user's deck
    ///   - length: Desired story length (determines word count)
    ///   - direction: Study direction to filter progress
    /// - Returns: Selected words with meanings
    /// - Throws: AIStoryError.insufficientWords if not enough eligible words
    func selectWords(
        from allWords: [Word],
        for length: StoryLength,
        direction: StudyDirection = .enToTr
    ) throws -> [WordWithMeaning] {
        
        // Step 1: Filter eligible words (progress < 21 days)
        let eligibleWords = filterEligibleWords(from: allWords, direction: direction)
        
        // Step 2: Validate minimum requirement
        let minRequired = length.minDeckWords
        guard eligibleWords.count >= minRequired else {
            throw AIStoryError.insufficientWords(
                required: minRequired,
                available: eligibleWords.count
            )
        }
        
        // Step 3: Determine target count (random between min and max)
        let maxCount = min(eligibleWords.count, length.maxDeckWords)
        let targetCount = Int.random(in: minRequired...maxCount)
        
        // Step 4: Randomly select words
        let selectedWords = eligibleWords.shuffled().prefix(targetCount)
        
        // Step 5: Convert to WordWithMeaning
        return selectedWords.map { word in
            WordWithMeaning(
                id: word.id,
                english: word.english,
                turkish: word.turkish
            )
        }
    }
    
    // MARK: - Private Helpers
    
    /// Filter words with progress < 21 days
    /// Only recently reviewed words are eligible for story generation
    private func filterEligibleWords(
        from words: [Word],
        direction: StudyDirection
    ) -> [Word] {
        return words.filter { word in
            // Load progress for this word
            guard let progress = userDefaults.loadProgress(for: word.id, direction: direction) else {
                return false
            }
            
            // Only include if in review phase (not learning) and interval < 21 days
            // Learning phase words are excluded as they're too new
            return !progress.learningPhase && progress.intervalDays < maxProgressDays
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
