//
//  ContentValidator.swift
//  HocaLingo
//
//  Core/Utils/ContentValidator.swift
//  Input validation for AI story generation
//  Low-cost, client-side filtering before API call
//  Prevents inappropriate/illegal content without token usage
//

import Foundation

/// Content validator for story topics
/// Validates user input before sending to AI
/// Zero token cost - all validation happens locally
class ContentValidator {
    
    // MARK: - Blocked Keywords
    
    /// Inappropriate content keywords (Turkish)
    /// Keep this list minimal for performance
    private let blockedKeywords: Set<String> = [
        // Sexual content
        "seks", "sex", "porno", "porn", "sikiş", "fuck", "amcık", "yarrak", "taşak",
        "göt", "meme", "çıplak", "naked", "nude", "mastürbasyon", "oral",
        
        // Violence
        "öldür", "kill", "cinayet", "murder", "tecavüz", "rape", "işkence", "torture",
        "bomba", "bomb", "uyuşturucu", "drug", "kokain", "eroin",
        
        // Hate speech
        "piç", "orospu", "kahpe", "kaltak", "bitch", "whore", "sluts",
        
        // Common swear words
        "amk", "amq", "aq", "mk", "shit", "damn", "hell"
    ]
    
    /// Suspicious patterns (regex)
    private let suspiciousPatterns: [String] = [
        // Repeated characters (spam-like)
        "(.)\\1{4,}",  // Same char 5+ times: "aaaaa"
        
        // Excessive punctuation
        "[!?.]{5,}",   // 5+ punctuation marks
        
        // URL patterns (prevent external links)
        "http[s]?://",
        "www\\.",
        "\\.com|\\.net|\\.org"
    ]
    
    // MARK: - Validation
    
    /// Validate topic input
    /// - Parameter topic: User-provided topic
    /// - Returns: Validation result
    func validateTopic(_ topic: String?) -> ValidationResult {
        // Empty topic is OK (user can skip)
        guard let topic = topic, !topic.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .valid
        }
        
        let normalized = topic.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
        
        // Check blocked keywords
        for keyword in blockedKeywords {
            if normalized.contains(keyword) {
                return .invalid(reason: .inappropriateContent)
            }
        }
        
        // Check suspicious patterns
        for pattern in suspiciousPatterns {
            if normalized.range(of: pattern, options: .regularExpression) != nil {
                return .invalid(reason: .suspiciousPattern)
            }
        }
        
        // Check length (prevent token abuse)
        if topic.count > 100 {
            return .invalid(reason: .tooLong)
        }
        
        // Check minimum quality
        if topic.count < 2 {
            return .invalid(reason: .tooShort)
        }
        
        return .valid
    }
    
    /// Sanitize topic (remove excess whitespace, trim)
    /// - Parameter topic: Raw topic input
    /// - Returns: Cleaned topic
    func sanitizeTopic(_ topic: String?) -> String? {
        guard let topic = topic else { return nil }
        
        let cleaned = topic
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return cleaned.isEmpty ? nil : cleaned
    }
}

// MARK: - Validation Result

/// Result of content validation
enum ValidationResult {
    case valid
    case invalid(reason: InvalidReason)
    
    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let reason) = self {
            return reason.message
        }
        return nil
    }
}

/// Reasons for invalid content
enum InvalidReason {
    case inappropriateContent
    case suspiciousPattern
    case tooLong
    case tooShort
    
    var message: String {
        switch self {
        case .inappropriateContent:
            return "Lütfen uygun bir konu girin. Hikayeler eğitim amaçlı ve çocuklara uygun olmalıdır."
        case .suspiciousPattern:
            return "Geçersiz içerik tespit edildi. Lütfen normal bir konu girin."
        case .tooLong:
            return "Konu çok uzun. Lütfen daha kısa bir konu girin (max 100 karakter)."
        case .tooShort:
            return "Konu çok kısa. Lütfen en az 2 karakter girin."
        }
    }
}

// MARK: - Extension for AI Safety

extension ContentValidator {
    
    /// Get safety instructions for AI prompt
    /// These are added to every prompt to ensure safe content
    static var aiSafetyRules: String {
        return """
        
        ⚠️ MUTLAK İÇERİK KURALLARI:
        - Hikaye çocuklara uygun, eğitici ve pozitif olmalı
        - Şiddet, cinsellik, uyuşturucu, nefret söylemi içermemeli
        - Yasal ve etik sınırlar içinde kalmalı
        - İlham verici ve öğretici olmalı
        """
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension ContentValidator {
    /// Test validation with sample inputs
    func debugTest() {
        let tests: [(String, Bool)] = [
            ("Uzay macerası", true),
            ("Kahve molası", true),
            ("seks hikayesi", false),
            ("http://malicious.com", false),
            ("a", false),
            ("aaaaaaaaaa", false)
        ]
        
        for (topic, shouldBeValid) in tests {
            let result = validateTopic(topic)
            let passed = result.isValid == shouldBeValid
            print("\(passed ? "✅" : "❌") '\(topic)' -> \(result)")
        }
    }
}
#endif
