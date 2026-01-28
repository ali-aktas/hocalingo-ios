//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX v3: Both HomeView and StudyView use tab binding
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
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("home_tab", systemImage: "house.fill")
                }
                .tag(0)
            
            // Study Tab - ✅ FIXED: Added binding
            StudyView(selectedTab: $selectedTab)
                .tabItem {
                    Label("study_tab", systemImage: "rectangle.portrait.on.rectangle.portrait.angled.fill")
                }
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(themeAccentColor)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    // MARK: - Theme Colors
    
    private var themeAccentColor: Color {
        Color(hex: "4ECDC4")
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        
        if isDark {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color(hex: "1C1C1E"))
        } else {
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = UIColor.systemBackground
        }
        
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
