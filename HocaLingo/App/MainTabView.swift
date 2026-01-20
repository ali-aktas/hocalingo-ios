//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX v2: Tab binding exposed for HomeView (eliminates duplicate StudyView navigation)
//  - Exposes selectedTab as @Binding
//  - HomeView can now switch to Study tab directly instead of navigating
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    
    // MARK: - State
    // ✅ CHANGED: Make selectedTab accessible to child views (HomeView needs it)
    @State private var selectedTab = 0
    
    // MARK: - Environment
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            // ✅ CRITICAL FIX: Pass selectedTab binding to HomeView
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("home_tab", systemImage: "house.fill")
                }
                .tag(0)  // ✅ Home = 0
            
            // Study Tab
            StudyView()
                .tabItem {
                    Label("study_tab", systemImage: "play.fill")
                }
                .tag(1)  // ✅ Study = 1
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(2)  // ✅ Profile = 2
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
