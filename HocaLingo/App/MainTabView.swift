//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX: Tab tags corrected (0-1-2 instead of 0-0-1)
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - State
    @State private var selectedTab = 0
    
    // MARK: - Environment
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("home_tab", systemImage: "house.fill")
                }
                .tag(0)  // ✅ Home = 0
            
            // Study Tab
            StudyView()
                .tabItem {
                    Label("study_tab", systemImage: "play.fill")
                }
                .tag(1)  // ✅ FIXED: Study = 1 (was 0, causing conflict!)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(2)  // ✅ FIXED: Profile = 2 (was 1)
        }
        // ✅ Theme-aware accent color
        .accentColor(themeAccentColor)
        // ✅ Theme-aware tab bar appearance
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    // MARK: - Theme Colors
    
    /// Dynamic accent color based on theme
    private var themeAccentColor: Color {
        // Use HocaLingo brand color (teal) - works in both themes
        Color(hex: "4ECDC4")
    }
    
    /// Configure tab bar appearance for theme support
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Check current theme
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        
        if isDark {
            // Dark theme tab bar
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "1C1C1E"))
        } else {
            // Light theme tab bar
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground
        }
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
