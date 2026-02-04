//
//  MainTabView.swift
//  HocaLingo
//
//  ✅ FIXED: Notification navigation with NotificationCenter (no bindings)
//  Location: HocaLingo/App/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @Namespace private var animation
    
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    private let accentColor = Color(hex: "4ECDC4")
    
    @State private var showPaywallOnLaunch = false
    @StateObject private var premiumManager = PremiumManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. CONTENT LAYER
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
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    tabButton(icon: "house", index: 0)
                    tabButton(icon: "rectangle.portrait.on.rectangle.portrait.angled", index: 1)
                    tabButton(icon: "person", index: 2)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                        .overlay {
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onAppear {
            // Rating trigger
            RatingManager.shared.checkAndShowRating()
            
            // 3-launch paywall trigger
            checkAndShowPaywall()
        }
        .sheet(isPresented: $showPaywallOnLaunch) {
            PremiumPaywallView()
        }
        // ✅ NEW: Listen for tab switching from notifications
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToTab"))) { notification in
            if let destination = notification.object as? String {
                DispatchQueue.main.async {
                    switch destination {
                    case "study":
                        selectedTab = 1
                    case "ai":
                        selectedTab = 0 // Home first, then AI opens
                    default:
                        break
                    }
                }
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            print("📱 Tab changed to: \(newValue)")
        }
    }
    
    // MARK: - 3-Launch Paywall Check
    private func checkAndShowPaywall() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding && premiumManager.shouldShowPaywallOnLaunch() {
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
