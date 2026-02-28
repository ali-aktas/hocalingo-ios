//
//  LevelScreen.swift
//  HocaLingo
//
//  Onboarding Screen 4: English level selection (4 options)
//  Maps to vocabulary package for post-onboarding word selection
//  Location: HocaLingo/Features/Onboarding/Screens/LevelScreen.swift
//

import SwiftUI

// MARK: - Level Screen (Screen 4)
struct LevelScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Title
            Text("onboarding_level_title")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            // 4 Level choices
            VStack(spacing: 12) {
                ForEach(EnglishLevel.allCases, id: \.rawValue) { level in
                    GlassCard(
                        icon: level.iconName,
                        iconColor: Color(hex: level.iconColor),
                        title: levelTitle(for: level),
                        subtitle: levelSubtitle(for: level),
                        isSelected: viewModel.onboardingData.englishLevel == level,
                        onTap: {
                            viewModel.selectLevel(level)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)

            // Mascot response area
            if let message = viewModel.mascotMessage,
               viewModel.currentStep == .level {
                HStack(alignment: .bottom, spacing: 8) {
                    Image("lingohoca_nod")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)

                    SpeechBubble(message: message)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()

            // Bottom: dots + button
            VStack(spacing: 20) {
                ProgressDots(
                    currentStep: OnboardingStep.level.progressIndex,
                    totalSteps: OnboardingStep.totalSteps
                )

                OnboardingButton(
                    title: "onboarding_button_continue",
                    isEnabled: viewModel.onboardingData.englishLevel != nil
                ) {
                    viewModel.clearMascotMessage()
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                contentOpacity = 1.0
            }
        }
    }

    // MARK: - Localized Titles
    private func levelTitle(for level: EnglishLevel) -> LocalizedStringKey {
        switch level {
        case .beginner:          return "onboarding_level_beginner"
        case .intermediate:      return "onboarding_level_intermediate"
        case .upperIntermediate: return "onboarding_level_upper"
        case .advanced:          return "onboarding_level_advanced"
        }
    }

    private func levelSubtitle(for level: EnglishLevel) -> LocalizedStringKey {
        switch level {
        case .beginner:          return "onboarding_level_beginner_desc"
        case .intermediate:      return "onboarding_level_intermediate_desc"
        case .upperIntermediate: return "onboarding_level_upper_desc"
        case .advanced:          return "onboarding_level_advanced_desc"
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(blobOffset: CGPoint(x: -30, y: 60))
        LevelScreen(viewModel: OnboardingViewModel())
    }
}
