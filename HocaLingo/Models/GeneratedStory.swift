//
//  GeneratedStory.swift
//  HocaLingo
//
//  AI Story Generation - Domain Models
//  Main story model and word highlighting support
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
    
    /// Find all ranges of this word in text (case-insensitive)
    /// Returns ranges for highlighting in AttributedString
    func ranges(in text: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchRange = text.startIndex..<text.endIndex
        
        while let range = text.range(
            of: english,
            options: [.caseInsensitive, .diacriticInsensitive],
            range: searchRange
        ) {
            ranges.append(range)
            searchRange = range.upperBound..<text.endIndex
        }
        
        return ranges
    }
    
    /// Check if word exists in text
    var exists: (String) -> Bool {
        return { text in
            return text.range(
                of: self.english,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) != nil
        }
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
