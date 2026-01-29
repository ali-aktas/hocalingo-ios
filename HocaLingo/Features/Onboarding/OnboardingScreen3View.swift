//
//  OnboardingScreen3View.swift
//  HocaLingo
//
//  ✅ FIXED: Background, overlay positioning, bottom text, success message
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
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                        .animation(.easeInOut(duration: 0.3), value: demoPhase)
                }
                
                // Card area
                ZStack {
                    if demoPhase == .completed {
                        // ✅ FIXED: Big success message in center
                        successMessage
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        demoCard
                    }
                }
                .frame(height: 460)
                .padding(.horizontal, 24)
                
                // ✅ FIXED: Bottom explanation text
                if demoPhase != .completed {
                    Text("Bildiğin kelimeleri sola kaydır,\nöğrenmek istediklerini sağa!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Bottom area
                VStack(spacing: 16) {
                    ProgressIndicator(
                        currentStep: viewModel.currentStep.progressValue,
                        totalSteps: viewModel.currentStep.totalSteps
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startAutoAnimation()
        }
    }
    
    // MARK: - Background Layer
    private var backgroundLayer: some View {
        ZStack {
            Color.themeBackground
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.themePrimaryButton.opacity(themeViewModel.isDarkMode(in: colorScheme) ? 0.12 : 0.05))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
        }
    }
    
    // MARK: - Success Message (Big and centered)
    private var successMessage: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "66BB6A"))
            
            Text("onboarding_feedback_added")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Demo Card
    private var demoCard: some View {
        GeometryReader { geometry in
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                
                // Card content
                VStack(spacing: 24) {
                    Spacer()
                    
                    Text(demoWord.0)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                        .frame(maxWidth: 200)
                    
                    Text(demoWord.1)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                
                // ✅ FIXED: Skip overlay (red - left) - positioned lower
                if skipAlpha > 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundColor(Color(hex: "EF5350"))
                                Text("GEÇ")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: "EF5350"))
                            }
                            Spacer()
                        }
                        .padding(.bottom, 60)  // ✅ Push down
                    }
                    .opacity(skipAlpha)
                }
                
                // ✅ FIXED: Learn overlay (green - right) - positioned lower
                if learnAlpha > 0 {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 56, weight: .bold))
                                    .foregroundColor(Color(hex: "66BB6A"))
                                Text("ÖĞREN")
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(Color(hex: "66BB6A"))
                            }
                            Spacer()
                        }
                        .padding(.bottom, 60)  // ✅ Push down
                    }
                    .opacity(learnAlpha)
                }
            }
            .frame(height: 400)
            .offset(cardOffset)
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if demoPhase == .userInteraction {
                            if gesture.translation.width > 0 {
                                cardOffset = gesture.translation
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
        
        if translation.width > threshold {
            completeSwipe(viewWidth: viewWidth)
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                cardOffset = .zero
            }
        }
    }
    
    private func completeSwipe(viewWidth: CGFloat) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
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
