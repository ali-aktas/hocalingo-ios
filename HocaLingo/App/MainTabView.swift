import SwiftUI

struct MainTabView: View {
    // MARK: - State
    @State private var selectedTab = 0
    @Namespace private var animation // Akıcı geçişler için
    
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // UI Sabitleri
    private let accentColor = Color(hex: "4ECDC4")
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Ana İçerik
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                StudyView(selectedTab: $selectedTab)
                    .tag(1)
                
                ProfileView()
                    .tag(2)
            }
            // Standart tab bar'ı gizle
            .toolbar(.hidden, for: .tabBar)
            
            // Modern Floating Tab Bar
            customFloatingTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // MARK: - Custom Tab Bar View
    private var customFloatingTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "house.fill", index: 0)
            tabButton(icon: "rectangle.portrait.on.rectangle.portrait.angled.fill", index: 1)
            tabButton(icon: "person.fill", index: 2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(.ultraThinMaterial) // Glassmorphism efekti
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 40) // Kenarlardan boşluk
        .padding(.bottom, 10)     // Safe area üzerinde yüzmesi için
    }
    
    @ViewBuilder
    private func tabButton(icon: String, index: Int) -> some View {
        let isSelected = selectedTab == index
        
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
            // Haptic Feedback (Dokunsal Titreşim)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .symbolVariant(isSelected ? .fill : .none)
                    .contentTransition(.symbolEffect(.replace)) // iOS 17+ Akıcı ikon değişimi
                    .foregroundStyle(isSelected ? accentColor : .secondary)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                
                // Seçili olanın altına küçük bir nokta (Indicator)
                if isSelected {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 4, height: 4)
                        .matchedGeometryEffect(id: "indicator", in: animation)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
        }
    }
}
