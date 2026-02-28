//
//  EmpathyScreen.swift
//  HocaLingo
//
//  Onboarding Screen 2: Emotional hook — "Which describes you?"
//  3 choices with glassmorphism cards + mascot speech bubble response
//  Location: HocaLingo/Features/Onboarding/Screens/EmpathyScreen.swift
//

import SwiftUI

// MARK: - Empathy Screen (Screen 2)
struct EmpathyScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Title
            Text("onboarding_empathy_title")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            // 3 Empathy choices
            VStack(spacing: 12) {
                ForEach(EmpathyChoice.allCases, id: \.rawValue) { choice in
                    GlassCard(
                        icon: choice.iconName,
                        iconColor: Color(hex: choice.iconColor),
                        title: empathyTitle(for: choice),
                        isSelected: viewModel.onboardingData.empathyChoice == choice,
                        onTap: {
                            viewModel.selectEmpathy(choice)
                        }
                    )
                }
            }
            .padding(.horizontal, 24)

            // Mascot + speech bubble area
            if let message = viewModel.mascotMessage,
               viewModel.currentStep == .empathy {
                HStack(alignment: .bottom, spacing: 8) {
                    Image("lingohoca_nod")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)

                    SpeechBubble(message: message)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()

            // Bottom: dots + button
            VStack(spacing: 20) {
                ProgressDots(
                    currentStep: OnboardingStep.empathy.progressIndex,
                    totalSteps: OnboardingStep.totalSteps
                )

                OnboardingButton(
                    title: "onboarding_button_continue",
                    isEnabled: viewModel.onboardingData.empathyChoice != nil
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
    private func empathyTitle(for choice: EmpathyChoice) -> LocalizedStringKey {
        switch choice {
        case .quitter:   return "onboarding_empathy_quitter"
        case .forgetful: return "onboarding_empathy_forgetful"
        case .noTime:    return "onboarding_empathy_no_time"
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(blobOffset: CGPoint(x: 40, y: -50))
        EmpathyScreen(viewModel: OnboardingViewModel())
    }
}
