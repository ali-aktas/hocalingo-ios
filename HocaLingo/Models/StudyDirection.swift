import Foundation

// MARK: - Study Direction Enum
/// Language study direction options
/// Only two directions: EN→TR and TR→EN (no mixed mode)
enum StudyDirection: String, Codable, CaseIterable {
    case enToTr = "en_tr"  // English to Turkish (matches Progress.swift format)
    case trToEn = "tr_en"  // Turkish to English
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .enToTr: return "English → Turkish"
        case .trToEn: return "Turkish → English"
        }
    }
}
