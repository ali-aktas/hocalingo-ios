import Foundation

// MARK: - Theme Mode Enum
/// App theme mode options
enum ThemeMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light Mode"
        case .dark: return "Dark Mode"
        }
    }
}
