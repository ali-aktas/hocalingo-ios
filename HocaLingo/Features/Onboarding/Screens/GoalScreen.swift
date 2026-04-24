//
//  GoalScreen.swift
//  HocaLingo
//
//  ✅ V2: Mascot + speech bubble (matching Empathy/Level pattern)
//  ✅ V2: Removed static explanation text block — mascot now carries the message
//  ✅ V2: Click sound added to GoalCard tap
//  Onboarding Screen 3: Learning goal → StudyDirection mapping
//  Location: HocaLingo/Features/Onboarding/Screens/GoalScreen.swift
//

import SwiftUI

// MARK: - Goal Screen (Screen 3)
struct GoalScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Title
            Text("onboarding_goal_title")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            // Two goal cards side by side
            HStack(spacing: 16) {
                // Understand card (EN → TR)
                GoalCard(
                    iconName: "eye.fill",
                    gradientColors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                    title: "onboarding_goal_understand",
                    subtitle: "onboarding_goal_understand_short",
                    isSelected: viewModel.onboardingData.learningGoal == .understand,
                    onTap: {
                        viewModel.selectGoal(.understand)
                    }
                )

                // Speak card (TR → EN)
                GoalCard(
                    iconName: "bubble.left.fill",
                    gradientColors: [Color(hex: "4ECDC4"), Color(hex: "36B5AB")],
                    title: "onboarding_goal_speak",
                    subtitle: "onboarding_goal_speak_short",
                    isSelected: viewModel.onboardingData.learningGoal == .speak,
                    onTap: {
                        viewModel.selectGoal(.speak)
                    }
                )
            }
            .padding(.horizontal, 24)

            // ✅ V2: Mascot response area (replaces old static explanation text)
            // Pattern matches Empathy + Level screens for visual consistency
            if let message = viewModel.mascotMessage,
               viewModel.currentStep == .goal {
                HStack(alignment: .bottom, spacing: 8) {
                    Image("lingohoca_nod")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)

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
                    currentStep: OnboardingStep.goal.progressIndex,
                    totalSteps: OnboardingStep.totalSteps
                )

                OnboardingButton(
                    title: "onboarding_button_continue",
                    isEnabled: viewModel.onboardingData.learningGoal != nil
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
}

// MARK: - Goal Card (Big Selection Card)
private struct GoalCard: View {
    let iconName: String
    let gradientColors: [Color]
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        // ✅ Click sound added here (applied from previous session, kept intact)
        Button(action: {
            SoundManager.shared.playClickSound()
            onTap()
        }) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Title
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Subtitle
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: isSelected
                                ? gradientColors
                                : [Color.white.opacity(0.06), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected
                            ? Color.white.opacity(0.3)
                            : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? gradientColors[0].opacity(0.3) : .clear,
                radius: 12,
                y: 6
            )
        }
        .buttonStyle(GlassCardPressStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Press Style
private struct GlassCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(blobOffset: CGPoint(x: 60, y: 20))
        GoalScreen(viewModel: OnboardingViewModel())
    }
}
