//
//  FirstWordSelectionView.swift
//  HocaLingo
//
//  ✅ V2: Soft limit reduced 20 → 15 (better first-session pacing)
//  🐛 V2 FIX: Soft-limit overlay now renders INSIDE the fullScreenCover
//            (was behind WordSelectionView — invisible to user)
//  One-time post-onboarding word selection with mascot intro + 15-word soft limit
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
    /// ✅ V2: Reduced from 20 → 15 (tighter first-session pacing)
    /// Only right-swipes count (saved as `selections.selected`)
    /// Left-swipes (hidden) and undo actions are NOT counted
    private let softLimit = 15
    
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
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.3), value: showIntro)
        // 🐛 V2 FIX: Wrap WordSelectionView in a ZStack and render the soft-limit
        //           overlay INSIDE the fullScreenCover so it appears ON TOP of the
        //           word cards instead of behind them.
        .fullScreenCover(isPresented: $showWordSelection) {
            NavigationStack {
                ZStack {
                    // Main word selection UI
                    WordSelectionView(packageId: packageId, selectedTab: $dummyTab)
                    
                    // ✅ Soft-limit dialog rendered on top of WordSelectionView
                    if showSoftLimitDialog {
                        softLimitOverlay
                            .transition(.opacity)
                            .zIndex(20)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: showSoftLimitDialog)
            }
        }
        .onChange(of: showWordSelection) { _, newValue in
            if !newValue { completeFirstSelection() }
        }
        // Intercept tab change (WordSelectionView sets tab=1 when "Start Learning")
        .onChange(of: dummyTab) { _, newValue in
            if newValue != 0 {
                completeFirstSelection()
            }
        }
        // Track selections via notification (posted on every swipe right)
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
                    SoundManager.shared.playClickSound()
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
                    SoundManager.shared.playClickSound()
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
                    SoundManager.shared.playClickSound()
                    showSoftLimitDialog = false
                    // Dismiss the fullScreenCover first, then complete.
                    // onChange(of: showWordSelection) will call completeFirstSelection().
                    showWordSelection = false
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
                    SoundManager.shared.playClickSound()
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
    
    /// Called on every `"WordsChanged"` notification (posted from WordSelectionViewModel.swipeRight).
    /// Shows the soft-limit dialog exactly once, the moment the user crosses the threshold.
    private func checkSelectionCount() {
        let selections = UserDefaultsManager.shared.getWordSelections(packageId: packageId)
        let count = selections.selected.count
        
        #if DEBUG
        print("🎯 FirstSelection check → count=\(count), tracker=\(selectedCountTracker), limit=\(softLimit), dialogShown=\(showSoftLimitDialog)")
        #endif
        
        // Show dialog at the moment of crossing the threshold (fires only once).
        // Condition:
        //   - count reached/exceeded the limit
        //   - dialog not already visible
        //   - previous tracker was BELOW the limit (ensures single-fire)
        if count >= softLimit && !showSoftLimitDialog && selectedCountTracker < softLimit {
            showSoftLimitDialog = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            #if DEBUG
            print("🎉 Soft limit reached! Showing dialog at \(count) words.")
            #endif
        }
        
        selectedCountTracker = count
    }
    
    private func completeFirstSelection() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Meta Event
        let selections = UserDefaultsManager.shared.getWordSelections(packageId: packageId)
        MetaEventManager.shared.logFirstWordSelectionCompleted(wordCount: selections.selected.count)
        MixpanelManager.shared.trackWordSelectionCompleted(packageId: packageId, wordsSelected: selections.selected.count, wordsSkipped: selections.hidden.count)
        
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
