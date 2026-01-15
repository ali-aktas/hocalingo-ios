import Foundation

// MARK: - Study Direction Enum
/// Language study direction options
enum StudyDirection: String, Codable, CaseIterable {
    case enToTr = "en_tr"  // English to Turkish (matches Progress.swift format)
    case trToEn = "tr_en"  // Turkish to English
    case mixed = "mixed"   // Mixed direction
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .enToTr: return "English → Turkish"
        case .trToEn: return "Turkish → English"
        case .mixed: return "Mixed"
        }
    }
}
