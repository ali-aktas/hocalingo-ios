//
//  GeminiAPIService.swift
//  HocaLingo
//
//  Core/API/GeminiAPIService.swift
//  Google Gemini API integration with URLSession
//  Model: gemini-2.5-flash
//

import Foundation

/// Gemini API service
/// Handles HTTP requests to Google Gemini API with retry logic and error handling
class GeminiAPIService {
    
    // MARK: - Configuration
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/"
    private let model = "gemini-2.0-flash-exp"
    private let timeout: TimeInterval = 30  // 30 seconds (AI generation can take time)
    
    // MARK: - Public Methods
    
    /// Generate story content using Gemini API
    /// - Parameters:
    ///   - apiKey: Gemini API key from Firebase Remote Config
    ///   - request: Configured request with prompt and settings
    /// - Returns: Generated content response
    /// - Throws: AIStoryError for various failure scenarios
    func generateStory(
        apiKey: String,
        request: GeminiRequest
    ) async throws -> GeminiResponse {
        
        // Build URL
        guard let url = URL(string: "\(baseURL)models/\(model):generateContent?key=\(apiKey)") else {
            throw AIStoryError.apiRequestFailed(message: "Invalid URL")
        }
        
        // Configure request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = timeout
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode body
        let encoder = JSONEncoder()
        do {
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw AIStoryError.apiRequestFailed(message: "Failed to encode request: \(error.localizedDescription)")
        }
        
        // Execute request
        let (data, response) = try await performRequest(urlRequest)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIStoryError.invalidResponse
        }
        
        // Handle HTTP errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = try? parseErrorResponse(from: data)
            throw AIStoryError.apiRequestFailed(
                message: errorMessage ?? "HTTP \(httpResponse.statusCode)"
            )
        }
        
        // Decode response
        let decoder = JSONDecoder()
        do {
            let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
            
            // Validate content
            guard geminiResponse.isValid() else {
                throw AIStoryError.emptyResponse
            }
            
            return geminiResponse
            
        } catch DecodingError.dataCorrupted {
            throw AIStoryError.invalidResponse
        } catch {
            throw AIStoryError.apiRequestFailed(message: "Decoding failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Perform URL request with error mapping
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            // Map URLError to AIStoryError
            switch error.code {
            case .timedOut:
                throw AIStoryError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw AIStoryError.networkError
            default:
                throw AIStoryError.apiRequestFailed(message: error.localizedDescription)
            }
        } catch {
            throw AIStoryError.unknown(error)
        }
    }
    
    /// Parse error response from Gemini API
    private func parseErrorResponse(from data: Data) throws -> String {
        let decoder = JSONDecoder()
        if let errorResponse = try? decoder.decode(GeminiErrorResponse.self, from: data) {
            return errorResponse.error.message
        }
        return "Unknown API error"
    }
}

// MARK: - Mock Service (for testing)

#if DEBUG
class MockGeminiAPIService: GeminiAPIService {
    var shouldFail = false
    var mockResponse: String = "Mock hikaye içeriği"
    
    override func generateStory(
        apiKey: String,
        request: GeminiRequest
    ) async throws -> GeminiResponse {
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        if shouldFail {
            throw AIStoryError.apiRequestFailed(message: "Mock error")
        }
        
        return GeminiResponse(
            candidates: [
                GeminiResponse.Candidate(
                    content: GeminiResponse.Candidate.Content(
                        parts: [
                            GeminiResponse.Candidate.Content.Part(text: mockResponse)
                        ]
                    )
                )
            ]
        )
    }
}
#endif
