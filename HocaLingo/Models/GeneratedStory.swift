//
//  GeneratedStory.swift
//  HocaLingo
//
//  AI Story Generation - Domain Models
//  ✅ UPDATED: Whole-word matching to fix substring issues
//  Location: HocaLingo/Models/GeneratedStory.swift
//

import Foundation

/// AI-generated story model
/// Contains story content, metadata, and vocabulary tracking
struct GeneratedStory: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let content: String
    let usedWordIds: [Int]           // Word IDs for tracking
    let usedWords: [WordWithMeaning] // Words with meanings for highlighting
    let topic: String?
    let type: StoryType
    let length: StoryLength
    let createdAt: Date
    var isFavorite: Bool
    
    /// Initialize new story
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        usedWordIds: [Int],
        usedWords: [WordWithMeaning],
        topic: String?,
        type: StoryType,
        length: StoryLength,
        createdAt: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.usedWordIds = usedWordIds
        self.usedWords = usedWords
        self.topic = topic
        self.type = type
        self.length = length
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
    
    /// Formatted creation date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// Story preview (first 80 characters)
    var preview: String {
        let preview = content.prefix(80)
        return preview.count < content.count ? "\(preview)..." : String(preview)
    }
}

/// Word with meaning for highlighting and interaction
/// Used in story detail view for tap-to-see-meaning feature
struct WordWithMeaning: Identifiable, Codable, Equatable {
    let id: Int        // Word ID from database
    let english: String
    let turkish: String
    
    /// ⚠️ DEPRECATED: Old substring matching (caused "sand" in "sandalye" issue)
    /// Use wholeWordRanges() instead
    func ranges(in text: String) -> [Range<String.Index>] {
        // This is kept for backward compatibility but should not be used
        return wholeWordRanges(in: text)
    }
    
    /// ✅ NEW: Whole-word matching with regex
    /// Fixes issues:
    /// - "sand" won't match "sandalye" ✅
    /// - "I" won't match "ı" in Turkish words ✅
    /// - Only matches complete words with word boundaries
    func wholeWordRanges(in text: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        
        // Escape special regex characters in word
        let escapedWord = NSRegularExpression.escapedPattern(for: english)
        
        // ✅ Word boundary pattern: \b word \b
        // This ensures we only match complete words
        let pattern = "\\b\(escapedWord)\\b"
        
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]
        ) else {
            return ranges
        }
        
        let nsRange = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: nsRange)
        
        for match in matches {
            if let range = Range(match.range, in: text) {
                ranges.append(range)
            }
        }
        
        return ranges
    }
    
    /// ✅ UPDATED: Check if word exists using whole-word matching
    func exists(in text: String) -> Bool {
        return !wholeWordRanges(in: text).isEmpty
    }
    
    /// ✅ NEW: Count occurrences in text (for validation)
    func countOccurrences(in text: String) -> Int {
        return wholeWordRanges(in: text).count
    }
}

// MARK: - Sorting Extensions

extension GeneratedStory {
    /// Sort by newest first
    static func byNewest(_ stories: [GeneratedStory]) -> [GeneratedStory] {
        return stories.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Filter favorites only
    static func favorites(from stories: [GeneratedStory]) -> [GeneratedStory] {
        return stories.filter { $0.isFavorite }
    }
    
    /// Filter by type
    static func byType(_ type: StoryType, from stories: [GeneratedStory]) -> [GeneratedStory] {
        return stories.filter { $0.type == type }
    }
}

// MARK: - Word Extraction Utility

extension GeneratedStory {
    /// ✅ NEW: Extract actually used words from content
    /// This replaces the old logic that showed all candidate words
    /// - Parameter candidateWords: Words that were sent to AI
    /// - Returns: Words actually used in the story (whole-word match)
    static func extractUsedWords(
        from content: String,
        candidateWords: [WordWithMeaning]
    ) -> [WordWithMeaning] {
        return candidateWords.filter { word in
            word.exists(in: content)
        }
    }
}
