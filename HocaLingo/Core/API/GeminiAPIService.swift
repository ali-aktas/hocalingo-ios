//
//  GeminiAPIService.swift
//  HocaLingo
//
//  Location: Core/API/GeminiAPIService.swift
//  ✅ FIXED: Corrected URL construction to match Android implementation
//

import Foundation

/// Gemini API service
/// Handles HTTP requests to Google Gemini API with retry logic and error handling
class GeminiAPIService {
    
    // MARK: - Configuration
    
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    // Sadece model ismini tutuyoruz, aksiyonu URL içinde belirleyeceğiz
    private let modelName = "gemini-2.5-flash"
    private let timeout: TimeInterval = 30
    
    // MARK: - Public Methods
    
    /// Generate story content using Gemini API
    func generateStory(
        apiKey: String,
        request: GeminiRequest
    ) async throws -> GeminiResponse {
        
        // ✅ CORRECTED URL: Android ile aynı yapıyı kuruyoruz
        // Base: .../v1beta
        // Path: /models/{modelName}:generateContent
        // Query: ?key={apiKey}
        let urlString = "\(baseURL)/models/\(modelName):generateContent?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
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
            // Eğer parse edemezsek en azından HTTP kodunu görelim
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
        // Gemini hata döndürdüğünde genellikle bu formatta döner
        if let errorResponse = try? decoder.decode(GeminiErrorResponse.self, from: data) {
            return errorResponse.error.message
        }
        
        // Eğer JSON değilse, gelen ham veriyi string olarak okumaya çalışalım (hata ayıklamak için)
        if let rawError = String(data: data, encoding: .utf8) {
            return "API Error Detail: \(rawError)"
        }
        
        return "Unknown API error"
    }
}
