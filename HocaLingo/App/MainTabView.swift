//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ NEW: 3-launch paywall system for free users
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    private let accentColor = Color(hex: "4ECDC4")
    
    // ✅ NEW: Paywall state
    @State private var showPaywallOnLaunch = false
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. CONTENT LAYER
            // ignoresSafeArea(.all) allows content to extend to bottom,
            // below home indicator
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
            
            // 2. TAB BAR LAYER
            // Using VStack to ensure no system blocks remain below the bar
            VStack {
                Spacer() // Push bar to bottom
                
                HStack(spacing: 0) {
                    tabButton(icon: "house", index: 0)
                    tabButton(icon: "rectangle.portrait.on.rectangle.portrait.angled", index: 1)
                    tabButton(icon: "person", index: 2)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    // Completely independent capsule
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                        .overlay {
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        }
                }
                // Determines how far up from the bottom of the screen it sits
                .padding(.bottom, 20)
                .padding(.horizontal, 30)
            }
            // CRITICAL: Prevents system from filling the space below the bar
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            // ✅ Rating trigger on app launch
            RatingManager.shared.checkAndShowRating()
            
            // ✅ NEW: 3-launch paywall trigger (only for free users, after onboarding)
            checkAndShowPaywall()
        }
        .sheet(isPresented: $showPaywallOnLaunch) {
            PremiumPaywallView()
        }
    }
    
    // MARK: - 3-Launch Paywall Check
    private func checkAndShowPaywall() {
        // Check if user has completed onboarding
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        // Only show paywall if user completed onboarding and should see it
        if hasCompletedOnboarding && premiumManager.shouldShowPaywallOnLaunch() {
            // Add small delay for better UX (let UI settle)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showPaywallOnLaunch = true
            }
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
                    .foregroundStyle(isSelected ? accentColor : Color.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
