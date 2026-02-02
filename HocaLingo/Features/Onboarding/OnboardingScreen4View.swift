//
//  OnboardingScreen4View.swift
//  HocaLingo
//
//  ✅ ENHANCED: Animated tap indicator, pulse effects, haptic feedback
//  Location: HocaLingo/Features/Onboarding/OnboardingScreen4View.swift
//

import SwiftUI

// MARK: - Onboarding Screen 4 (Study Demo)
struct OnboardingScreen4View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var studyPhase: StudyPhase = .beforeFlip
    @State private var isCardFlipped = false
    @State private var showWarning = false
    @State private var cardRotation: Double = 0
    
    // ✅ NEW: Tap indicator animation states
    @State private var tapIndicatorScale: CGFloat = 1.0
    @State private var tapIndicatorOpacity: Double = 0.8
    @State private var cardPulseScale: CGFloat = 1.0
    
    // Demo word
    private let demoWord = ("Apple", "Elma", "Her gün elma yerim")
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                // Instruction banner
                instructionBanner
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                
                // Card area
                ZStack {
                    demoFlipCard
                    
                    // ✅ NEW: Animated tap indicator (only before flip)
                    if studyPhase == .waitingForFlip {
                        tapIndicator
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 460)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 32)
                
                // Difficulty buttons
                difficultyButtons
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Progress indicator
                ProgressIndicator(
                    currentStep: viewModel.currentStep.progressValue,
                    totalSteps: viewModel.currentStep.totalSteps
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startDemoFlow()
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
    
    // MARK: - Instruction Banner
    private var instructionBanner: some View {
        VStack(spacing: 8) {
            Text(instructionText)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if showWarning {
                Text("onboarding_study_warning")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "F97316"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: studyPhase)
        .animation(.spring(response: 0.3), value: showWarning)
    }
    
    // MARK: - ✅ NEW: Tap Indicator
    private var tapIndicator: some View {
        VStack(spacing: 12) {
            // Finger icon with pulse
            Text("☝️")
                .font(.system(size: 64))
                .scaleEffect(tapIndicatorScale)
                .opacity(tapIndicatorOpacity)
                .shadow(color: Color.themePrimaryButton.opacity(0.4), radius: 20)
            
            // "Tap" text
            Text("Dokun")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimaryButton)
                .opacity(tapIndicatorOpacity)
        }
        .offset(y: -50)
        .onAppear {
            startTapIndicatorAnimation()
        }
    }
    
    // MARK: - Demo Flip Card
    private var demoFlipCard: some View {
        ZStack {
            // ✅ 3D depth shadow
            depthShadow
            
            // ✅ NEW: Pulse ring effect (only when waiting for tap)
            if studyPhase == .waitingForFlip {
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.themePrimaryButton.opacity(0.4), lineWidth: 3)
                    .frame(height: 400)
                    .scaleEffect(cardPulseScale)
                    .opacity(2 - cardPulseScale)
                    .onAppear {
                        startCardPulseAnimation()
                    }
            }
            
            // Main card
            ZStack {
                // Back side (Turkish)
                cardFace(
                    mainText: demoWord.1,
                    exampleText: demoWord.2,
                    isFront: false
                )
                .opacity(cardRotation > 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(cardRotation - 180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.3
                )
                
                // Front side (English)
                cardFace(
                    mainText: demoWord.0,
                    exampleText: "",
                    isFront: true
                )
                .opacity(cardRotation <= 90 ? 1 : 0)
                .rotation3DEffect(
                    .degrees(cardRotation),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.3
                )
            }
        }
        .onTapGesture {
            if studyPhase == .waitingForFlip {
                performFlip()
            }
        }
    }
    
    // MARK: - Depth Shadow
    private var depthShadow: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.black.opacity(0.18))
            .frame(maxWidth: .infinity, maxHeight: 400)
            .offset(y: 8)
            .rotation3DEffect(
                .degrees(cardRotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
    }
    
    // MARK: - Card Face
    private func cardFace(mainText: String, exampleText: String, isFront: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "6366F1").opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            VStack(spacing: 20) {
                Spacer()
                
                Text(mainText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if !exampleText.isEmpty {
                    Text(exampleText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
        .frame(height: 400)
    }
    
    // MARK: - Difficulty Buttons
    private var difficultyButtons: some View {
        HStack(spacing: 12) {
            DifficultyButton(
                title: "onboarding_difficulty_hard",
                timeText: "5 dk",
                color: Color(hex: "EF4444"),
                isEnabled: studyPhase == .difficultySelection
            ) {
                selectDifficulty(.hard)
            }
            
            DifficultyButton(
                title: "onboarding_difficulty_medium",
                timeText: "Sonra",
                color: Color(hex: "F97316"),
                isEnabled: studyPhase == .difficultySelection
            ) {
                selectDifficulty(.medium)
            }
            
            DifficultyButton(
                title: "onboarding_difficulty_easy",
                timeText: "Bugün",
                color: Color(hex: "10B981"),
                isEnabled: studyPhase == .difficultySelection
            ) {
                selectDifficulty(.easy)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var instructionText: LocalizedStringKey {
        switch studyPhase {
        case .beforeFlip:
            return "onboarding_study_hint1"
        case .waitingForFlip:
            return "onboarding_study_hint2"
        case .difficultySelection:
            return "onboarding_study_hint3"
        case .completed:
            return "onboarding_success"
        }
    }
    
    // MARK: - ✅ NEW: Tap Indicator Animation
    private func startTapIndicatorAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            tapIndicatorScale = 1.2
            tapIndicatorOpacity = 1.0
        }
    }
    
    // MARK: - ✅ NEW: Card Pulse Animation
    private func startCardPulseAnimation() {
        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            cardPulseScale = 1.15
        }
    }
    
    // MARK: - Demo Flow Control
    private func startDemoFlow() {
        // Wait a moment, then enable flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                studyPhase = .waitingForFlip
            }
        }
    }
    
    private func performFlip() {
        // ✅ NEW: Haptic feedback on tap
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            cardRotation = 180
            isCardFlipped = true
        }
        
        // Enable difficulty buttons after flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                studyPhase = .difficultySelection
            }
            
            // Show warning after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showWarning = true
                }
            }
        }
    }
    
    private func selectDifficulty(_ difficulty: DifficultyLevel) {
        // ✅ NEW: Different haptic feedback based on difficulty
        switch difficulty {
        case .easy:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .hard:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        
        withAnimation {
            studyPhase = .completed
        }
        
        // Complete onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewModel.nextStep()
        }
    }
}

// MARK: - Study Phase Enum
private enum StudyPhase {
    case beforeFlip
    case waitingForFlip
    case difficultySelection
    case completed
}

// MARK: - Difficulty Level
private enum DifficultyLevel {
    case easy, medium, hard
}

// MARK: - Difficulty Button
private struct DifficultyButton: View {
    let title: LocalizedStringKey
    let timeText: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                
                Text(timeText)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .opacity(0.8)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isEnabled ? 1.0 : 0.4))
            )
        }
        .disabled(!isEnabled)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Preview
#Preview {
    OnboardingScreen4View(viewModel: OnboardingViewModel())
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
