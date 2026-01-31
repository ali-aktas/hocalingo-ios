//
//  ContentCleaner.swift
//  HocaLingo
//
//  Core/Utils/ContentCleaner.swift
//  Content processing and cleaning service
//  7-step algorithm for clean, readable story output
//

import Foundation

/// Content cleaner for AI-generated stories
/// Removes markdown, formatting, and extracts title
class ContentCleaner {
    
    /// Clean AI-generated content and extract title
    /// - Parameter rawContent: Raw text from Gemini API
    /// - Returns: Tuple of (title, cleanedContent)
    func clean(_ rawContent: String) -> (title: String, content: String) {
        
        var lines = rawContent.components(separatedBy: "\n")
        
        // Step 1: Extract title (first non-empty line)
        let title = extractTitle(from: &lines)
        
        // Step 2: Join remaining lines
        var content = lines.joined(separator: "\n")
        
        // Step 3: Remove markdown formatting
        content = removeMarkdown(from: content)
        
        // Step 4: Remove parenthetical translations
        content = removeParentheticals(from: content)
        
        // Step 5: Remove heading markers (##, ###)
        content = removeHeadings(from: content)
        
        // Step 6: Clean whitespace
        content = cleanWhitespace(in: content)
        
        // Step 7: Fix incomplete sentences
        content = fixIncompleteSentences(in: content)
        
        // Step 8: Final trim
        content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (
            title: title.isEmpty ? "Hikaye" : title,
            content: content
        )
    }
    
    // MARK: - Cleaning Steps
    
    /// Step 1: Extract title from first line
    private func extractTitle(from lines: inout [String]) -> String {
        // Remove empty lines from start
        while let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.removeFirst()
        }
        
        // First non-empty line is title
        guard !lines.isEmpty else { return "" }
        let title = lines.removeFirst().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove empty line after title (if exists)
        if let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
            lines.removeFirst()
        }
        
        // Limit title to 3 words or ~18 characters
        return limitTitle(title)
    }
    
    /// Limit title length
    private func limitTitle(_ title: String) -> String {
        let words = title.components(separatedBy: .whitespaces)
        let threeWords = words.prefix(3).joined(separator: " ")
        
        // If still too long, truncate to 18 chars
        if threeWords.count > 20 {
            let truncated = String(threeWords.prefix(18))
            return truncated + "..."
        }
        
        return threeWords
    }
    
    /// Step 3: Remove markdown formatting
    private func removeMarkdown(from text: String) -> String {
        var cleaned = text
        
        // Remove bold (**text**)
        cleaned = cleaned.replacingOccurrences(of: "**", with: "")
        
        // Remove italic (*text*)
        cleaned = cleaned.replacingOccurrences(of: "*", with: "")
        
        // Remove underline (_text_)
        cleaned = cleaned.replacingOccurrences(of: "_", with: "")
        
        // Remove backticks (`code`)
        cleaned = cleaned.replacingOccurrences(of: "`", with: "")
        
        return cleaned
    }
    
    /// Step 4: Remove parenthetical translations
    /// Example: "young (genç)" → "young"
    private func removeParentheticals(from text: String) -> String {
        // Regex: Remove space + (anything)
        let pattern = "\\s*\\([^)]+\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(text.startIndex..., in: text)
        
        guard let regex = regex else { return text }
        
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: ""
        )
    }
    
    /// Step 5: Remove heading markers (##, ###, etc.)
    private func removeHeadings(from text: String) -> String {
        // Regex: Lines starting with # (heading markers)
        let pattern = "^#+\\s+.*$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(text.startIndex..., in: text)
        
        guard let regex = regex else { return text }
        
        return regex.stringByReplacingMatches(
            in: text,
            options: [],
            range: range,
            withTemplate: ""
        )
    }
    
    /// Step 6: Clean excessive whitespace
    private func cleanWhitespace(in text: String) -> String {
        var cleaned = text
        
        // Multiple spaces → single space
        let spacePattern = "\\s+"
        if let spaceRegex = try? NSRegularExpression(pattern: spacePattern, options: []) {
            let range = NSRange(cleaned.startIndex..., in: cleaned)
            cleaned = spaceRegex.stringByReplacingMatches(
                in: cleaned,
                options: [],
                range: range,
                withTemplate: " "
            )
        }
        
        // Multiple newlines → double newline
        let newlinePattern = "\n{3,}"
        if let newlineRegex = try? NSRegularExpression(pattern: newlinePattern, options: []) {
            let range = NSRange(cleaned.startIndex..., in: cleaned)
            cleaned = newlineRegex.stringByReplacingMatches(
                in: cleaned,
                options: [],
                range: range,
                withTemplate: "\n\n"
            )
        }
        
        return cleaned
    }
    
    /// Step 7: Fix incomplete sentences
    /// Ensures content ends with proper punctuation
    private func fixIncompleteSentences(in text: String) -> String {
        guard !text.isEmpty else { return text }
        
        let punctuation: Set<Character> = [".", "!", "?"]
        
        // If already ends with punctuation, return as is
        if let last = text.last, punctuation.contains(last) {
            return text
        }
        
        // Find last punctuation and truncate
        if let lastPunctuationIndex = text.lastIndex(where: { punctuation.contains($0) }) {
            return String(text[...lastPunctuationIndex])
        }
        
        // No punctuation found, add period at end
        return text + "."
    }
}

// MARK: - String Extension

extension String {
    /// Remove all whitespace and newlines
    var withoutWhitespace: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    /// Check if string contains only whitespace
    var isWhitespace: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
