//
//  OnboardingScreen4View.swift
//  HocaLingo
//
//  ✅ FINAL VERSION: Shadow removed from flip card
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
    
    // Demo word
    private let demoWord = ("Apple", "Elma", "I eat an apple every day")
    
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
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if showWarning {
                Text("onboarding_study_warning")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "F97316"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: studyPhase)
        .animation(.spring(response: 0.3), value: showWarning)
    }
    
    // MARK: - Demo Flip Card
    private var demoFlipCard: some View {
        ZStack {
            // ✅ NO depth shadow - clean minimal look!
            
            // Main card (NO extra shadow - clean look!)
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
            // ✅ NO .shadow() here - depth shadow is enough!
        }
        .onTapGesture {
            if studyPhase == .waitingForFlip {
                performFlip()
            }
        }
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
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                if !exampleText.isEmpty {
                    Text(exampleText)
                        .font(.system(size: 14, weight: .regular))
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            cardRotation = 180
            isCardFlipped = true
        }
        
        // Enable difficulty buttons after flip
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                studyPhase = .difficultySelection
            }
        }
    }
    
    private func selectDifficulty(_ difficulty: Difficulty) {
        // Show soft warning for easy/medium
        if difficulty != .hard && !showWarning {
            withAnimation(.spring(response: 0.3)) {
                showWarning = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 0.3)) {
                    showWarning = false
                }
            }
        }
        
        // Complete demo
        studyPhase = .completed
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        // Complete onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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

// MARK: - Difficulty Enum
private enum Difficulty {
    case hard, medium, easy
}

// MARK: - Difficulty Button
private struct DifficultyButton: View {
    let title: LocalizedStringKey
    let timeText: String
    let color: Color
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isEnabled ? .white : .white.opacity(0.5))
                
                Text(timeText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isEnabled ? .white.opacity(0.8) : .white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? color : color.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isEnabled ? .white.opacity(0.2) : .clear, lineWidth: 1)
            )
            .shadow(
                color: isEnabled ? color.opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
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
