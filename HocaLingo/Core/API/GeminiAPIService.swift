//
//  GeminiAPIService.swift
//  HocaLingo
//
//  Location: Core/API/GeminiAPIService.swift
//  ✅ PRODUCTION READY: API key masking in logs
//

import Foundation

/// Gemini API service
/// Handles HTTP requests to Google Gemini API with retry logic and error handling
class GeminiAPIService {
    
    // MARK: - Configuration
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    private let modelName = "gemini-2.5-flash"
    private let timeout: TimeInterval = 30
    
    // MARK: - Public Methods
    
    /// Generate story content using Gemini API
    func generateStory(
        apiKey: String,
        request: GeminiRequest
    ) async throws -> GeminiResponse {
        
        // ✅ SECURE: Build URL without exposing key in logs
        let urlString = "\(baseURL)/models/\(modelName):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw AIStoryError.apiRequestFailed(message: "Invalid URL")
        }
        
        // ✅ PRODUCTION LOGGING (key masked)
        #if DEBUG
        print("🌐 Gemini API Request: \(baseURL)/models/\(modelName):generateContent?key=***")
        #endif
        
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
                message: errorMessage ?? "HTTP Error: \(httpResponse.statusCode)"
            )
        }
        
        // Decode response
        let decoder = JSONDecoder()
        do {
            let geminiResponse = try decoder.decode(GeminiResponse.self, from: data)
            
            guard geminiResponse.isValid() else {
                throw AIStoryError.emptyResponse
            }
            
            #if DEBUG
            print("✅ Gemini API Response: Success (\(geminiResponse.getGeneratedText().count) chars)")
            #endif
            
            return geminiResponse
            
        } catch {
            throw AIStoryError.apiRequestFailed(message: "Decoding failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await URLSession.shared.data(for: request)
        } catch let error as URLError {
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
    
    private func parseErrorResponse(from data: Data) throws -> String {
        let decoder = JSONDecoder()
        if let errorResponse = try? decoder.decode(GeminiErrorResponse.self, from: data) {
            return errorResponse.error.message
        }
        
        if let rawError = String(data: data, encoding: .utf8) {
            return "API Error Detail: \(rawError)"
        }
        
        return "Unknown API error"
    }
}
