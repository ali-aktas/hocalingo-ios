import SwiftUI

// MARK: - Main Tab View
/// Root navigation structure with 3 tabs: Home, Study, Profile
/// Location: HocaLingo/App/MainTabView.swift
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Label("home_tab", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: Study
            StudyMainView()
                .tabItem {
                    Label("study_tab", systemImage: "book.fill")
                }
                .tag(1)
            
            // Tab 3: Profile
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

// MARK: - Temporary Placeholder Views
// These will be replaced with actual implementations

struct StudyMainView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("study_screen_title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Coming Soon")
                    .foregroundColor(.gray)
            }
            .navigationTitle("study_tab")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("profile_screen_title")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Coming Soon")
                    .foregroundColor(.gray)
            }
            .navigationTitle("profile_tab")
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
