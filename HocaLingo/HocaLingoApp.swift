//
//  HocaLingoApp.swift
//  HocaLingo
//
//  ✅ UPDATED: App-wide theme management integrated
//  Created by Auralian on 15.01.2026.
//

import SwiftUI

@main
struct HocaLingoApp: App {
    
    // MARK: - Theme Management
    /// App-wide theme view model (singleton for consistent state)
    @StateObject private var themeViewModel = ThemeViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // ✅ Apply theme globally to entire app
                .preferredColorScheme(themeViewModel.effectiveColorScheme)
                // ✅ Inject theme view model into environment
                .environment(\.themeViewModel, themeViewModel)
        }
    }
}
