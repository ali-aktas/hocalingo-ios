//
//  MainTabView.swift
//  HocaLingo
//
//  FINAL VERSION - Home and Profile only
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("home_tab", systemImage: "house.fill")
                }
                .tag(0)
            
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(1)
        }
        .accentColor(Color(hex: "4ECDC4"))
    }
}

#Preview {
    MainTabView()
}
