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
            
            StudyView()
                .tabItem {
                    Label("study_tab", systemImage: "book.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("profile_tab", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
