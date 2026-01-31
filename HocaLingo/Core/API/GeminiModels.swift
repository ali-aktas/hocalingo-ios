//
//  GeminiModels.swift
//  HocaLingo
//
//  Core/API/GeminiModels.swift
//  Gemini API Data Transfer Objects (DTOs)
//  Request/Response models for Google Gemini 2.5 Flash API
//

import Foundation

// MARK: - Request Models

/// Main request wrapper for Gemini API
/// Documentation: https://ai.google.dev/docs
struct GeminiRequest: Codable {
    let contents: [Content]
    let generationConfig: GenerationConfig
    
    struct Content: Codable {
        let parts: [Part]
        
        struct Part: Codable {
            let text: String
        }
    }
    
    struct GenerationConfig: Codable {
        let temperature: Double
        let topK: Int
        let topP: Double
        let maxOutputTokens: Int
        let thinkingConfig: ThinkingConfig?
        
        struct ThinkingConfig: Codable {
            let thinkingBudget: Int
        }
    }
    
    /// Create request from prompt with dynamic token limit
    /// - Parameters:
    ///   - prompt: AI prompt text
    ///   - maxTokens: Maximum output tokens (cost optimization)
    /// - Returns: Configured GeminiRequest
    static func create(prompt: String, maxTokens: Int) -> GeminiRequest {
        return GeminiRequest(
            contents: [
                Content(parts: [Content.Part(text: prompt)])
            ],
            generationConfig: GenerationConfig(
                temperature: 0.9,        // Creativity
                topK: 40,                // Diversity
                topP: 0.95,              // Nucleus sampling
                maxOutputTokens: maxTokens,
                thinkingConfig: GenerationConfig.ThinkingConfig(
                    thinkingBudget: 0    // 0 = thinking disabled (cost optimization)
                )
            )
        )
    }
}

// MARK: - Response Models

/// Main response wrapper from Gemini API
struct GeminiResponse: Codable {
    let candidates: [Candidate]
    
    struct Candidate: Codable {
        let content: Content
        
        struct Content: Codable {
            let parts: [Part]?
            
            struct Part: Codable {
                let text: String
            }
        }
    }
    
    /// Extract generated text from first candidate
    /// - Returns: Generated text or empty string if no candidates/parts
    func getGeneratedText() -> String {
        return candidates.first?
            .content
            .parts?
            .first?
            .text ?? ""
    }
    
    /// Check if response is valid (has content)
    func isValid() -> Bool {
        return !candidates.isEmpty && !getGeneratedText().isEmpty
    }
}

// MARK: - Error Response

/// Gemini API error response
struct GeminiErrorResponse: Codable {
    let error: ErrorDetail
    
    struct ErrorDetail: Codable {
        let code: Int
        let message: String
        let status: String
    }
}
