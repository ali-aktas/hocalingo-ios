//
//  SummaryScreen.swift
//  HocaLingo
//
//  Onboarding Screen 5: Personalized summary + celebration + launch
//  Shows recap of selections and routes to word selection after onboarding
//  Location: HocaLingo/Features/Onboarding/Screens/SummaryScreen.swift
//

import SwiftUI
import Lottie

// MARK: - Summary Screen (Screen 5)
struct SummaryScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var mascotOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Confetti overlay
            ZStack {
                if showConfetti {
                    LottieView(
                        animationName: "confetti_minimal",
                        loopMode: .playOnce,
                        animationSpeed: 1.0
                    )
                    .frame(width: 300, height: 300)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                }

                // Mascot celebrating
                Image("lingohoca_celebrate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .opacity(mascotOpacity)
            }
            .padding(.bottom, 24)

            // Summary card
            summaryCard
                .scaleEffect(cardScale)
                .opacity(cardOpacity)
                .padding(.horizontal, 24)

            Spacer()

            // Bottom: dots + launch button
            VStack(spacing: 20) {
                ProgressDots(
                    currentStep: OnboardingStep.summary.progressIndex,
                    totalSteps: OnboardingStep.totalSteps
                )

                OnboardingButton(title: "onboarding_button_launch") {
                    viewModel.nextStep()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(buttonOpacity)
        }
        .onAppear {
            runEntryAnimations()
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 20) {
            // Header
            Text("onboarding_summary_title")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)

            // Goal row
            SummaryRow(
                icon: goalIcon,
                iconColor: goalColor,
                label: "onboarding_summary_goal",
                value: goalText
            )

            // Level row
            SummaryRow(
                icon: viewModel.onboardingData.englishLevel?.iconName ?? "book.fill",
                iconColor: Color(hex: viewModel.onboardingData.englishLevel?.iconColor ?? "6366F1"),
                label: "onboarding_summary_level",
                value: levelText
            )

            // Ready row
            SummaryRow(
                icon: "sparkles",
                iconColor: Color(hex: "4ECDC4"),
                label: "onboarding_summary_ready",
                value: "onboarding_summary_ready_value"
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    // MARK: - Computed Properties
    private var goalIcon: String {
        viewModel.onboardingData.learningGoal == .speak ? "bubble.left.fill" : "eye.fill"
    }

    private var goalColor: Color {
        viewModel.onboardingData.learningGoal == .speak
            ? Color(hex: "4ECDC4")
            : Color(hex: "6366F1")
    }

    private var goalText: LocalizedStringKey {
        viewModel.onboardingData.learningGoal == .speak
            ? "onboarding_summary_goal_speak"
            : "onboarding_summary_goal_understand"
    }

    private var levelText: LocalizedStringKey {
        guard let level = viewModel.onboardingData.englishLevel else {
            return "onboarding_level_intermediate"
        }
        switch level {
        case .beginner:          return "onboarding_level_beginner"
        case .intermediate:      return "onboarding_level_intermediate"
        case .upperIntermediate: return "onboarding_level_upper"
        case .advanced:          return "onboarding_level_advanced"
        }
    }

    // MARK: - Entry Animations
    private func runEntryAnimations() {
        // Mascot appears
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            mascotOpacity = 1.0
        }

        // Confetti fires
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            showConfetti = true
        }

        // Card scales in
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.5)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }

        // Button appears
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Summary Row
private struct SummaryRow: View {
    let icon: String
    let iconColor: Color
    let label: LocalizedStringKey
    let value: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Label
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.white.opacity(0.5))

            Spacer()

            // Value
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(blobOffset: CGPoint(x: 0, y: 80))
        SummaryScreen(viewModel: {
            let vm = OnboardingViewModel()
            vm.onboardingData.learningGoal = .speak
            vm.onboardingData.englishLevel = .intermediate
            return vm
        }())
    }
}
