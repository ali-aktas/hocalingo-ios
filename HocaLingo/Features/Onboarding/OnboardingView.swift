//
//  OnboardingView.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Premium 5-screen onboarding container
//  Dark theme, smooth transitions, skip support, completion overlay
//  Location: HocaLingo/Features/Onboarding/OnboardingView.swift
//

import SwiftUI
import Lottie

// MARK: - Onboarding View (Main Container)
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            // Dark background (theme-independent, always dark)
            OnboardingBackground(blobOffset: blobPosition)

            // Screen content based on current step
            Group {
                switch viewModel.currentStep {
                case .promise:
                    PromiseScreen(viewModel: viewModel)
                        .transition(screenTransition)

                case .empathy:
                    EmpathyScreen(viewModel: viewModel)
                        .transition(screenTransition)

                case .goal:
                    GoalScreen(viewModel: viewModel)
                        .transition(screenTransition)

                case .level:
                    LevelScreen(viewModel: viewModel)
                        .transition(screenTransition)

                case .summary:
                    SummaryScreen(viewModel: viewModel)
                        .transition(screenTransition)
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.currentStep)

            // Skip button (visible on screens 1-4, not on summary)
            if viewModel.currentStep != .summary {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.skipOnboarding()
                        }) {
                            Text("onboarding_button_skip")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }
                    Spacer()
                }
            }

            // Completion overlay
            if viewModel.showCompletionAnimation {
                completionOverlay
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: viewModel.showCompletionAnimation) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    // MARK: - Transition
    private var screenTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    // MARK: - Dynamic Blob Position (shifts per screen)
    private var blobPosition: CGPoint {
        switch viewModel.currentStep {
        case .promise:  return CGPoint(x: -40, y: -100)
        case .empathy:  return CGPoint(x: 50, y: -50)
        case .goal:     return CGPoint(x: 60, y: 30)
        case .level:    return CGPoint(x: -30, y: 80)
        case .summary:  return CGPoint(x: 0, y: -40)
        }
    }

    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Checkmark success (Lottie)
                LottieView(
                    animationName: "checkmark_success",
                    loopMode: .playOnce,
                    animationSpeed: 1.0
                )
                .frame(width: 120, height: 120)

                Text("onboarding_success")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
