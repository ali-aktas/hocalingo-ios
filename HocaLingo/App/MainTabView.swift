import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    private let accentColor = Color(hex: "4ECDC4")
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. İÇERİK KATMANI
            // ignoresSafeArea(.all) sayesinde içerik en alta,
            // home indicator'ın altına kadar uzanır.
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                StudyView(selectedTab: $selectedTab)
                    .tag(1)
                
                ProfileView()
                    .tag(2)
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.all)
            
            // 2. TAB BAR KATMANI
            // Barın altında hiçbir sistem bloğu kalmaması için VStack kullanıyoruz
            VStack {
                Spacer() // Barı en alta iter
                
                HStack(spacing: 0) {
                    tabButton(icon: "house", index: 0)
                    tabButton(icon: "rectangle.portrait.on.rectangle.portrait.angled", index: 1)
                    tabButton(icon: "person", index: 2)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    // Tamamen bağımsız bir kapsül
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                        .overlay {
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        }
                }
                // Ekranın en altından ne kadar yukarıda duracağını belirler
                .padding(.bottom, 20)
                .padding(.horizontal, 30)
            }
            // Bu kısım çok kritik: Barın altındaki alanı sistemin doldurmasını engeller
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
    
    @ViewBuilder
    private func tabButton(icon: String, index: Int) -> some View {
        let isSelected = selectedTab == index
        
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedTab = index
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            VStack(spacing: 0) {
                Image(systemName: isSelected ? icon + ".fill" : icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(isSelected ? accentColor : .gray.opacity(0.8))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background {
                        if isSelected {
                            Circle()
                                .fill(accentColor.opacity(0.15))
                                // MatchedGeometry ile ikonlar arası akıcı geçiş
                                .matchedGeometryEffect(id: "TAB_INDICATOR", in: animation)
                                .frame(width: 48, height: 48)
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
