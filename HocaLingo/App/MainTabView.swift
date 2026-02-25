//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ FIXED: Safe area issue resolved with old VStack structure
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showPaywallOnLaunch = false
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Content Layer (4 Tabs)
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                StudyView(selectedTab: $selectedTab)
                    .tag(1)
                
                AIStoryMainView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
            }
            .toolbar(.hidden, for: .tabBar)
            .ignoresSafeArea(.all)
            
            // MARK: - Custom Tab Bar Layer (Old Structure)
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    // Home Tab
                    tabBarButton(
                        icon: "house.fill",
                        label: "tab_home",
                        index: 0
                    )
                    
                    // Study Tab
                    tabBarButton(
                        icon: "rectangle.portrait.on.rectangle.portrait.angled.fill",
                        label: "tab_study",
                        index: 1
                    )
                    
                    // AI Story Tab
                    tabBarButton(
                        icon: "sparkle",
                        label: "tab_ai",
                        index: 2
                    )
                    
                    // Profile Tab
                    tabBarButton(
                        icon: "person.fill",
                        label: "tab_profile",
                        index: 3
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background {
                    ZStack {
                        // Glassmorphism background
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                isDarkMode
                                    ? Color(hex: "1C1C1E").opacity(0.95)
                                    : Color.white.opacity(0.95)
                            )
                        
                        // Subtle border
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.05),
                                        isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.08),
                        radius: 20,
                        x: 0,
                        y: -5
                    )
                }
                .padding(.bottom, 18)
                .padding(.horizontal, 24)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            RatingManager.shared.checkAndShowRating()
            checkAndShowPaywall()
        }
        .sheet(isPresented: $showPaywallOnLaunch) {
            PremiumPaywallView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
            if let destination = notification.object as? String {
                switch destination {
                case "study": selectedTab = 1
                case "home": selectedTab = 0
                case "profile": selectedTab = 3
                case "ai_assistant": selectedTab = 2
                default: break
                }
            }
        }
    }
    
    // MARK: - Tab Bar Button
    @ViewBuilder
    private func tabBarButton(icon: String, label: String, index: Int) -> some View {
        let isSelected = selectedTab == index
        
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            SoundManager.shared.playClickSound()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    // Selected background
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.themePrimaryButton.opacity(0.15),
                                        Color.themePrimaryButton.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "selected_background", in: animation)
                    }
                    
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(
                            isSelected
                                ? LinearGradient(
                                    colors: [
                                        Color.themePrimaryButton,
                                        Color.themePrimaryButtonGradientEnd
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        isDarkMode ? Color.white.opacity(0.5) : Color.black.opacity(0.4),
                                        isDarkMode ? Color.white.opacity(0.5) : Color.black.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                }
                .frame(height: 44)
                
                // Label
                Text(LocalizedStringKey(label))
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(
                        isSelected
                            ? Color.themePrimaryButton
                            : (isDarkMode ? Color.white.opacity(0.5) : Color.black.opacity(0.4))
                    )
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabBarScaleButtonStyle())
    }
    
    // MARK: - Helpers
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
    
    private func checkAndShowPaywall() {
        let launchCount = UserDefaults.standard.integer(forKey: "app_launch_count")
        if launchCount == 3 && !premiumManager.isPremium {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showPaywallOnLaunch = true
            }
        }
    }
}

// MARK: - Scale Button Style
struct TabBarScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environment(\.themeViewModel, ThemeViewModel())
}
