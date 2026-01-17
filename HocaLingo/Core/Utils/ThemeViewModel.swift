//
//  ThemeViewModel.swift
//  HocaLingo
//
//  Centralized theme management for the app
//  Adapted from Android's ThemeViewModel.kt
//  Location: HocaLingo/Core/Utils/ThemeViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Theme View Model
/// Central theme manager for the entire app
/// Handles theme switching (Light, Dark, System) with persistence
class ThemeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentTheme: ThemeMode = .system
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Singleton (Optional - for global access)
    static let shared = ThemeViewModel()
    
    // MARK: - Initialization
    init() {
        loadThemePreference()
    }
    
    // MARK: - Theme Loading
    
    /// Load saved theme preference from UserDefaults
    private func loadThemePreference() {
        let savedTheme = userDefaults.loadThemeMode()
        currentTheme = savedTheme
        print("✅ Theme loaded: \(savedTheme.rawValue)")
    }
    
    // MARK: - Theme Update
    
    /// Update theme mode (called from Profile screen)
    /// - Parameter newTheme: New theme to apply
    func updateTheme(to newTheme: ThemeMode) {
        currentTheme = newTheme
        userDefaults.saveThemeMode(newTheme)
        print("🎨 Theme updated to: \(newTheme.rawValue)")
    }
    
    /// Toggle between Light and Dark (System → Light → Dark → System)
    func toggleTheme() {
        let newTheme: ThemeMode
        switch currentTheme {
        case .system:
            newTheme = .light
        case .light:
            newTheme = .dark
        case .dark:
            newTheme = .system
        }
        updateTheme(to: newTheme)
    }
    
    // MARK: - Computed Properties
    
    /// Get effective ColorScheme based on current theme
    /// Used by SwiftUI's .preferredColorScheme modifier
    var effectiveColorScheme: ColorScheme? {
        switch currentTheme {
        case .system:
            return nil  // Let system decide
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    /// Check if currently using dark theme (for conditional UI logic)
    func isDarkMode(in colorScheme: ColorScheme) -> Bool {
        switch currentTheme {
        case .system:
            return colorScheme == .dark
        case .light:
            return false
        case .dark:
            return true
        }
    }
}

// MARK: - SwiftUI Environment Key
/// Environment key for accessing ThemeViewModel throughout the app
struct ThemeViewModelKey: EnvironmentKey {
    static let defaultValue = ThemeViewModel.shared
}

extension EnvironmentValues {
    var themeViewModel: ThemeViewModel {
        get { self[ThemeViewModelKey.self] }
        set { self[ThemeViewModelKey.self] = newValue }
    }
}
