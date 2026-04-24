//
//  OnboardingView.swift
//  HocaLingo
//
//  ✅ V2: Back button added (screens 2-4)
//  ✅ V2: Skip button hidden on Promise screen (full brand focus)
//  ✅ V2: Bidirectional screen transition (reads isMovingBack flag)
//  Dark theme, smooth transitions, completion overlay
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

            // ✅ V2: Top bar — Back (left) + Skip (right)
            // Both hidden on Promise (full brand focus) and Summary (can't back/skip)
            if viewModel.currentStep != .promise && viewModel.currentStep != .summary {
                VStack {
                    HStack {
                        // Back button — only when allowed
                        if viewModel.canGoBack {
                            Button(action: {
                                SoundManager.shared.playClickSound()
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                viewModel.previousStep()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 13, weight: .bold))
                                    Text("onboarding_button_back")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(Color.white.opacity(0.55))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.06))
                                )
                            }
                            .padding(.leading, 16)
                            .padding(.top, 12)
                        }
                        
                        Spacer()
                        
                        // Skip button
                        Button(action: {
                            SoundManager.shared.playClickSound()
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
    /// ✅ V2: Bidirectional — reads isMovingBack flag from ViewModel
    /// Forward: new screen enters from trailing (right), old exits to leading (left)
    /// Backward: new screen enters from leading (left), old exits to trailing (right)
    private var screenTransition: AnyTransition {
        if viewModel.isMovingBack {
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        } else {
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        }
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
                .frame(width: 200, height: 200)

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
