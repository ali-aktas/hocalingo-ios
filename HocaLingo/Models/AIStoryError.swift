//
//  AIStoryError.swift
//  HocaLingo
//
//  AI Story Generation - Error Types
//  Comprehensive error handling for all story generation scenarios
//

import Foundation

/// AI Story feature errors
/// Covers quota, API, validation, and business logic errors
enum AIStoryError: LocalizedError, Equatable {
    // Quota errors
    case quotaExceeded(remaining: Int, limit: Int)
    case quotaLoadFailed
    
    // Word selection errors
    case insufficientWords(required: Int, available: Int)
    case noWordsAvailable
    case wordLoadFailed
    
    // API errors
    case apiKeyMissing
    case apiRequestFailed(message: String)
    case emptyResponse
    case invalidResponse
    case timeout
    case networkError
    
    // Content errors
    case contentCleaningFailed
    case titleExtractionFailed
    case invalidContent
    
    // Storage errors
    case saveFailed
    case loadFailed
    case deleteFailed
    
    // General errors
    case unknown(Error)
    
    /// User-facing error description
    var errorDescription: String? {
        switch self {
        // Quota errors
        case .quotaExceeded(let remaining, let limit):
            if limit == 30 {
                return "Aylık 30 hikaye limitine ulaştınız. Yeni ay başında devam edebilirsiniz."
            } else {
                return "Aylık 3 hikaye limitine ulaştınız. Premium ile 30 hikaye yazın!"
            }
            
        case .quotaLoadFailed:
            return "Kota bilgileri yüklenemedi. Lütfen tekrar deneyin."
        
        // Word selection errors
        case .insufficientWords(let required, let available):
            return "Yeterli kelime bulunamadı. En az \(required) kelime gerekli (mevcut: \(available)). Daha fazla kelime öğrenin!"
            
        case .noWordsAvailable:
            return "Kullanılabilir kelime bulunamadı. Lütfen daha fazla kelime öğrenin."
            
        case .wordLoadFailed:
            return "Kelimeler yüklenemedi. Lütfen tekrar deneyin."
        
        // API errors
        case .apiKeyMissing:
            return "API anahtarı bulunamadı. Lütfen uygulamayı güncelleyin."
            
        case .apiRequestFailed(let message):
            return "API hatası: \(message)"
            
        case .emptyResponse:
            return "Yapay zeka yanıt vermedi. Lütfen tekrar deneyin."
            
        case .invalidResponse:
            return "Geçersiz yanıt alındı. Lütfen tekrar deneyin."
            
        case .timeout:
            return "İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin."
            
        case .networkError:
            return "Ağ hatası. Lütfen internet bağlantınızı kontrol edin."
        
        // Content errors
        case .contentCleaningFailed:
            return "İçerik işlenemedi. Lütfen tekrar deneyin."
            
        case .titleExtractionFailed:
            return "Başlık oluşturulamadı. Lütfen tekrar deneyin."
            
        case .invalidContent:
            return "Geçersiz içerik. Lütfen tekrar deneyin."
        
        // Storage errors
        case .saveFailed:
            return "Hikaye kaydedilemedi. Lütfen tekrar deneyin."
            
        case .loadFailed:
            return "Hikayeler yüklenemedi. Lütfen tekrar deneyin."
            
        case .deleteFailed:
            return "Hikaye silinemedi. Lütfen tekrar deneyin."
        
        // General
        case .unknown(let error):
            return "Beklenmeyen hata: \(error.localizedDescription)"
        }
    }
    
    /// Failure reason for debugging
    var failureReason: String? {
        switch self {
        case .quotaExceeded:
            return "Monthly quota limit reached"
        case .insufficientWords(let required, let available):
            return "Not enough words available: required \(required), available \(available)"
        case .apiRequestFailed(let message):
            return message
        case .timeout:
            return "Request timeout (30 seconds)"
        case .unknown(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
    
    /// Recovery suggestion for user
    var recoverySuggestion: String? {
        switch self {
        case .quotaExceeded(_, let limit):
            if limit == 30 {
                return "Yeni ay başında tekrar deneyin."
            } else {
                return "Premium'a yükselterek 30 hikaye yazın."
            }
            
        case .insufficientWords:
            return "Daha fazla kelime öğrenerek tekrar deneyin."
            
        case .timeout, .networkError:
            return "İnternet bağlantınızı kontrol edin ve tekrar deneyin."
            
        case .apiKeyMissing:
            return "Uygulamayı App Store'dan güncelleyin."
            
        default:
            return "Lütfen tekrar deneyin. Sorun devam ederse destek ekibiyle iletişime geçin."
        }
    }
}

// MARK: - Error Equatable Conformance

extension AIStoryError {
    static func == (lhs: AIStoryError, rhs: AIStoryError) -> Bool {
        switch (lhs, rhs) {
        case (.quotaExceeded(let l1, let l2), .quotaExceeded(let r1, let r2)):
            return l1 == r1 && l2 == r2
        case (.insufficientWords(let l1, let l2), .insufficientWords(let r1, let r2)):
            return l1 == r1 && l2 == r2
        case (.apiRequestFailed(let l), .apiRequestFailed(let r)):
            return l == r
        case (.quotaLoadFailed, .quotaLoadFailed),
             (.noWordsAvailable, .noWordsAvailable),
             (.wordLoadFailed, .wordLoadFailed),
             (.apiKeyMissing, .apiKeyMissing),
             (.emptyResponse, .emptyResponse),
             (.invalidResponse, .invalidResponse),
             (.timeout, .timeout),
             (.networkError, .networkError),
             (.contentCleaningFailed, .contentCleaningFailed),
             (.titleExtractionFailed, .titleExtractionFailed),
             (.invalidContent, .invalidContent),
             (.saveFailed, .saveFailed),
             (.loadFailed, .loadFailed),
             (.deleteFailed, .deleteFailed):
            return true
        default:
            return false
        }
    }
}
