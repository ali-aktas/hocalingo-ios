//
//  OnboardingScreen3View.swift
//  HocaLingo
//
//  ✅ ENHANCED: Animated arrow, hand gesture, pulse effects, haptic feedback, swipe lock
//  Location: HocaLingo/Features/Onboarding/OnboardingScreen3View.swift
//

import SwiftUI

// MARK: - Onboarding Screen 3 (Swipe Demo)
struct OnboardingScreen3View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var demoPhase: DemoPhase = .initial
    @State private var cardOffset: CGSize = .zero
    @State private var hasShownAutoAnimation = false
    
    // ✅ NEW: Animation states for indicators
    @State private var arrowScale: CGFloat = 1.0
    @State private var arrowOpacity: Double = 0.6
    @State private var handOffset: CGFloat = 0
    @State private var showWrongDirectionFeedback = false
    
    // Demo word
    private let demoWord = ("Hello", "Merhaba")
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                // Instruction text
                if demoPhase != .completed {
                    Text(instructionText)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .animation(.easeInOut(duration: 0.3), value: demoPhase)
                }
                
                // Card area
                ZStack {
                    if demoPhase == .completed {
                        successMessage
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        demoCard
                    }
                }
                .frame(height: 460)
                .padding(.horizontal, 24)
                
                // Bottom explanation text
                if demoPhase != .completed {
                    VStack(spacing: 12) {
                        Text("Bildiğin kelimeleri sola kaydır,\nöğrenmek istediklerini sağa!")
                            .font(.system(size: 14))
                            .foregroundColor(.themeSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        // ✅ NEW: Animated hand gesture (only during user interaction)
                        if demoPhase == .userInteraction {
                            handGestureIndicator
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startAutoAnimation()
            startArrowPulseAnimation()
        }
    }
    
    // MARK: - Background Layer
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hex: "1A1625"),
                    Color(hex: "211A2E")
                ] : [
                    Color(hex: "FBF2FF"),
                    Color(hex: "FAF1FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
        }
        
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
    
    // MARK: - Success Message
    private var successMessage: some View {
        VStack(spacing: 20) {
            // Big checkmark
            ZStack {
                Circle()
                    .fill(Color.accentGreen)
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.accentGreen.opacity(0.4), radius: 20)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text("onboarding_feedback_added")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Demo Card
    private var demoCard: some View {
        GeometryReader { geometry in
            ZStack {
                // Card
                VStack(spacing: 24) {
                    // English word
                    Text(demoWord.0)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                    
                    // Turkish meaning
                    Text(demoWord.1)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.themeSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color.themeCard)
                .cornerRadius(24)
                .shadow(color: Color.themeShadow, radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.themeBorder, lineWidth: 1)
                )
                
                // ✅ NEW: Animated arrow indicator (only during user interaction)
                if demoPhase == .userInteraction {
                    animatedArrowIndicator
                        .offset(x: 120, y: 0)
                }
                
                // ✅ ENHANCED: Swipe direction indicators with better styling
                HStack(spacing: 0) {
                    // Skip (Left)
                    VStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        
                        Text("GEÇ")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                    }
                    .frame(width: 120)
                    .opacity(skipAlpha)
                    .offset(x: -20)
                    
                    Spacer()
                    
                    // Learn (Right)
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentGreen)
                        
                        Text("ÖĞREN")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.accentGreen)
                    }
                    .frame(width: 120)
                    .opacity(learnAlpha)
                    .offset(x: 20)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
                
                // ✅ NEW: Wrong direction feedback (red flash)
                if showWrongDirectionFeedback {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.red.opacity(0.3))
                        .frame(height: 300)
                        .transition(.opacity)
                }
            }
            .frame(height: 400)
            .offset(cardOffset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if demoPhase == .userInteraction {
                            // ✅ NEW: Only allow right swipe
                            if gesture.translation.width > 0 {
                                cardOffset = gesture.translation
                            } else {
                                // ✅ NEW: Show wrong direction feedback
                                showWrongDirectionFeedback(for: gesture.translation.width)
                            }
                        }
                    }
                    .onEnded { gesture in
                        if demoPhase == .userInteraction {
                            handleSwipeEnd(translation: gesture.translation, viewWidth: geometry.size.width)
                        }
                    }
            )
        }
    }
    
    // MARK: - ✅ NEW: Animated Arrow Indicator
    private var animatedArrowIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.right")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.accentGreen)
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.accentGreen)
        }
        .scaleEffect(arrowScale)
        .opacity(arrowOpacity)
        .shadow(color: Color.accentGreen.opacity(0.6), radius: 10)
    }
    
    // MARK: - ✅ NEW: Hand Gesture Indicator
    private var handGestureIndicator: some View {
        HStack(spacing: 8) {
            Text("👉")
                .font(.system(size: 32))
                .offset(x: handOffset)
            
            Text("👉")
                .font(.system(size: 32))
                .offset(x: handOffset)
                .opacity(0.7)
            
            Text("👉")
                .font(.system(size: 32))
                .offset(x: handOffset)
                .opacity(0.4)
        }
        .onAppear {
            startHandGestureAnimation()
        }
    }
    
    // MARK: - Computed Properties
    private var instructionText: LocalizedStringKey {
        switch demoPhase {
        case .initial, .autoAnimation:
            return "onboarding_swipe_hint_initial"
        case .userInteraction:
            return "onboarding_swipe_hint_action"
        case .completed:
            return ""
        }
    }
    
    private var skipAlpha: Double {
        guard cardOffset.width < 0 else { return 0 }
        return min(abs(Double(cardOffset.width)) / 100, 1.0)
    }
    
    private var learnAlpha: Double {
        guard cardOffset.width > 0 else { return 0 }
        return min(Double(cardOffset.width) / 100, 1.0)
    }
    
    private var rotation: Double {
        return Double(cardOffset.width) / 25
    }
    
    // MARK: - ✅ NEW: Arrow Pulse Animation
    private func startArrowPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            arrowScale = 1.2
            arrowOpacity = 1.0
        }
    }
    
    // MARK: - ✅ NEW: Hand Gesture Animation
    private func startHandGestureAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            handOffset = 20
        }
    }
    
    // MARK: - ✅ NEW: Wrong Direction Feedback
    private func showWrongDirectionFeedback(for width: CGFloat) {
        // Only trigger if significant left swipe attempt
        guard width < -30 else { return }
        
        // ✅ Haptic feedback for wrong direction
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        // Visual feedback
        withAnimation(.easeInOut(duration: 0.2)) {
            showWrongDirectionFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showWrongDirectionFeedback = false
            }
        }
    }
    
    // MARK: - Auto Animation
    private func startAutoAnimation() {
        guard !hasShownAutoAnimation else { return }
        hasShownAutoAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            demoPhase = .autoAnimation
            
            // 1. Swipe left
            withAnimation(.easeInOut(duration: 0.8)) {
                cardOffset = CGSize(width: -80, height: 0)
            }
            
            // 2. Return to center
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    cardOffset = .zero
                }
                
                // 3. Swipe right
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        cardOffset = CGSize(width: 80, height: 0)
                    }
                    
                    // 4. Return and enable interaction
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            cardOffset = .zero
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            demoPhase = .userInteraction
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Swipe Handling
    private func handleSwipeEnd(translation: CGSize, viewWidth: CGFloat) {
        let threshold: CGFloat = 100
        
        // ✅ UPDATED: Only handle right swipe
        if translation.width > threshold {
            completeSwipe(viewWidth: viewWidth)
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardOffset = .zero
            }
        }
    }
    
    private func completeSwipe(viewWidth: CGFloat) {
        // ✅ NEW: Success haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = CGSize(width: viewWidth * 1.5, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation {
                demoPhase = .completed
            }
            
            // Auto-proceed to next screen
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.nextStep()
            }
        }
    }
}

// MARK: - Demo Phase Enum
private enum DemoPhase {
    case initial
    case autoAnimation
    case userInteraction
    case completed
}

// MARK: - Preview
#Preview {
    OnboardingScreen3View(viewModel: OnboardingViewModel())
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
