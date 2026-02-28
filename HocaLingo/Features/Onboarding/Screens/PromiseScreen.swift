//
//  PromiseScreen.swift
//  HocaLingo
//
//  Onboarding Screen 1: Brand promise with mascot entrance animation
//  "Dil bilgisi yok. Sadece kelime." + "Günde 10 dakika yeter."
//  Location: HocaLingo/Features/Onboarding/Screens/PromiseScreen.swift
//

import SwiftUI
import Lottie

// MARK: - Promise Screen (Screen 1)
struct PromiseScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel

    // Entry animations
    @State private var mascotScale: CGFloat = 0.3
    @State private var mascotOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var sparkleVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Sparkle ambient behind mascot
            ZStack {
                if sparkleVisible {
                    LottieView(
                        animationName: "sparkle_ambient",
                        loopMode: .loop,
                        animationSpeed: 0.5
                    )
                    .frame(width: 350, height: 350)
                    .opacity(0.4)
                    .allowsHitTesting(false)
                }

                // Mascot with entrance animation
                Image("lingohoca_wave")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .scaleEffect(mascotScale)
                    .opacity(mascotOpacity)
            }
            .padding(.bottom, 40)

            // Main promise text
            VStack(spacing: 12) {
                Text("onboarding_promise_title")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("onboarding_promise_subtitle")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .opacity(textOpacity)

            Spacer()

            // Bottom: dots + button
            VStack(spacing: 20) {
                ProgressDots(
                    currentStep: OnboardingStep.promise.progressIndex,
                    totalSteps: OnboardingStep.totalSteps
                )

                OnboardingButton(title: "onboarding_button_start") {
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

    // MARK: - Entry Animations
    private func runEntryAnimations() {
        // Mascot bounces in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.2)) {
            mascotScale = 1.0
            mascotOpacity = 1.0
        }

        // Sparkle appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sparkleVisible = true
        }

        // Text fades in
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            textOpacity = 1.0
        }

        // Button fades in
        withAnimation(.easeOut(duration: 0.4).delay(0.9)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        OnboardingBackground(blobOffset: CGPoint(x: -40, y: -100))
        PromiseScreen(viewModel: OnboardingViewModel())
    }
}
