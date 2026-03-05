//
//  FirstWordSelectionView.swift
//  HocaLingo
//
//  ✅ NEW: One-time post-onboarding word selection
//  OnboardingBackground + mascot intro + soft 20-word limit
//  Location: Features/Selection/FirstWordSelectionView.swift
//

import SwiftUI

// MARK: - First Word Selection View
struct FirstWordSelectionView: View {
    
    @Binding var hasCompletedFirstWordSelection: Bool
    
    @State private var showIntro: Bool = true
    @State private var dummyTab: Int = 0
    @State private var selectedCountTracker: Int = 0
    @State private var showSoftLimitDialog: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    @State private var showWordSelection: Bool = false
    
    // MARK: - Constants
    private let softLimit = 20
    
    // MARK: - Package from Onboarding
    private var packageId: String {
        UserDefaultsManager.shared.loadSelectedPackage() ?? "standard_a1_001"
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            if showIntro {
                introScreen
                    .transition(.opacity)
            } else {
                Color.clear
            }
            
            // Soft limit dialog overlay
            if showSoftLimitDialog {
                softLimitOverlay
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: showIntro)
        .fullScreenCover(isPresented: $showWordSelection) {
            NavigationStack {
                WordSelectionView(packageId: packageId, selectedTab: $dummyTab)
            }
        }
        .onChange(of: showWordSelection) { _, newValue in
            if !newValue { completeFirstSelection() }
        }
        .animation(.easeInOut(duration: 0.25), value: showSoftLimitDialog)
        // Intercept tab change (WordSelectionView sets tab=1 when "Start Learning")
        .onChange(of: dummyTab) { _, newValue in
            if newValue != 0 {
                completeFirstSelection()
            }
        }
        // Track selections via notification
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WordsChanged"))) { _ in
            checkSelectionCount()
        }
    }
    
    // MARK: - Intro Screen (Mascot + OnboardingBackground)
    private var introScreen: some View {
        ZStack {
            // Same background as onboarding
            OnboardingBackground(blobOffset: CGPoint(x: 20, y: -40))
            
            VStack(spacing: 0) {
                Spacer()
                
                // Mascot — large and prominent
                Image("lingohoca1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 24)
                
                // Title — hook
                Text(LocalizedStringKey("first_selection_intro_title"))
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 28)
                
                // Instruction cards
                VStack(spacing: 12) {
                    instructionCard(
                        emoji: "✅",
                        text: "first_selection_swipe_right",
                        bgColor: Color(hex: "66BB6A").opacity(0.15),
                        borderColor: Color(hex: "66BB6A").opacity(0.3)
                    )
                    
                    instructionCard(
                        emoji: "❌",
                        text: "first_selection_swipe_left",
                        bgColor: Color(hex: "EF5350").opacity(0.15),
                        borderColor: Color(hex: "EF5350").opacity(0.3)
                    )
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Start button (reuses onboarding style)
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    withAnimation {
                        showIntro = false
                        showWordSelection = true
                    }
                }) {
                    Text(LocalizedStringKey("first_selection_start"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "0D0B1A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "4ECDC4"))
                        )
                        .shadow(color: Color(hex: "4ECDC4").opacity(0.4), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                
                // Skip text
                Button(action: {
                    completeFirstSelection()
                }) {
                    Text(LocalizedStringKey("first_selection_skip"))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: - Instruction Card
    private func instructionCard(
        emoji: String,
        text: LocalizedStringKey,
        bgColor: Color,
        borderColor: Color
    ) -> some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Soft Limit Dialog
    private var softLimitOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Celebration icon
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 52))
                    .foregroundColor(Color(hex: "FFD700"))
                
                // Title
                Text(LocalizedStringKey("first_selection_soft_limit_title"))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Message
                Text(LocalizedStringKey("first_selection_soft_limit_message"))
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                
                // Primary: Start learning → goes to Study tab
                Button(action: {
                    showSoftLimitDialog = false
                    completeFirstSelection()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.fill")
                        Text(LocalizedStringKey("first_selection_start_learning"))
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "0D0B1A"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "4ECDC4"))
                    .cornerRadius(14)
                    .shadow(color: Color(hex: "4ECDC4").opacity(0.4), radius: 10, x: 0, y: 5)
                }
                
                // Secondary: Continue selecting
                Button(action: {
                    showSoftLimitDialog = false
                }) {
                    Text(LocalizedStringKey("first_selection_continue"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "2A2438"))
                    .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 36)
        }
    }
    
    // MARK: - Logic
    
    private func checkSelectionCount() {
        let selections = UserDefaultsManager.shared.getWordSelections(packageId: packageId)
        let count = selections.selected.count
        
        // Show soft limit dialog at 20 (only once per crossing)
        if count >= softLimit && !showSoftLimitDialog && selectedCountTracker < softLimit {
            showSoftLimitDialog = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        selectedCountTracker = count
    }
    
    private func completeFirstSelection() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Meta Event
        let selections = UserDefaultsManager.shared.getWordSelections(packageId: packageId)
        MetaEventManager.shared.logFirstWordSelectionCompleted(wordCount: selections.selected.count)
        
        // Flag: MainTabView should open on Study tab (index 1)
        UserDefaults.standard.set(true, forKey: "shouldOpenStudyAfterFirstSelection")
        
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedFirstWordSelection = true
        }
        
        print("✅ First word selection completed → Study tab")
    }
    
    // MARK: - Theme
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}

// MARK: - Preview
#Preview {
    FirstWordSelectionView(hasCompletedFirstWordSelection: .constant(false))
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
