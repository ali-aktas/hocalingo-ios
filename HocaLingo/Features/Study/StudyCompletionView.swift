//
//  StudyCompletionView.swift
//  HocaLingo
//
//  ✅ UPDATED: Lottie confetti + checkmark animations for dopamine hit
//  ✅ Celebration sound on session complete
//  ✅ Staggered animation: checkmark → confetti → text → buttons
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI
import Lottie

// MARK: - Study Completion View
struct StudyCompletionView: View {
    @Binding var selectedTab: Int
    let onContinue: () -> Void
    let onRestart: () -> Void
    
    // Sheet lives in StudyView — this is a binding
    @Binding var showPackageSelection: Bool

    @State private var animateSuccess = false
    @State private var showConfetti = false
    @State private var showCheckmark = false
    @State private var currentMessageIndex = 0

    // Localization key pairs: (title_key, subtitle_key)
    private let messageKeys: [(String, String)] = [
        ("study_completion_title_1", "study_completion_subtitle_1"),
        ("study_completion_title_2", "study_completion_subtitle_2"),
        ("study_completion_title_3", "study_completion_subtitle_3"),
        ("study_completion_title_4", "study_completion_subtitle_4"),
        ("study_completion_title_5", "study_completion_subtitle_5")
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            // LAYER 1: Full-screen confetti (behind content)
            if showConfetti {
                LottieView(
                    animationName: "confetti_minimal",
                    loopMode: .playOnce,
                    animationSpeed: 0.7
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .transition(.opacity)
            }

            // LAYER 2: Main content
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Lottie checkmark replaces static Image
                    ZStack {
                        // Subtle sparkle ambient behind checkmark
                        if showCheckmark {
                            LottieView(
                                animationName: "sparkle_ambient",
                                loopMode: .loop,
                                animationSpeed: 0.5
                            )
                            .frame(width: 220, height: 220)
                            .opacity(0.4)
                            .allowsHitTesting(false)
                        }
                        
                        if showCheckmark {
                            LottieView(
                                animationName: "checkmark_success",
                                loopMode: .playOnce,
                                animationSpeed: 1.0
                            )
                            .frame(width: 160, height: 160)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                        }
                    }
                    .frame(width: 220, height: 220)

                    VStack(spacing: 12) {
                        // Title
                        Text(L(messageKeys[currentMessageIndex].0))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)

                        // Subtitle
                        Text(L(messageKeys[currentMessageIndex].1))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateSuccess ? 1.0 : 0.0)
                    .offset(y: animateSuccess ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: animateSuccess)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    // Home button
                    Button(action: {
                        selectedTab = 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text(L("study_completion_home_button"))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 12, x: 0, y: 6)
                    }

                    // Package selection button — triggers sheet in StudyView
                    Button(action: {
                        showPackageSelection = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 18))
                            Text(L("study_completion_packages_button"))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "4ECDC4").opacity(0.12))
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animateSuccess ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.4).delay(0.6), value: animateSuccess)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            currentMessageIndex = Int.random(in: 0..<messageKeys.count)
            startCelebrationSequence()
        }
    }
    
    // MARK: - Celebration Animation Sequence
    
    /// Staggered animation: sound → checkmark → confetti → text → buttons
    private func startCelebrationSequence() {
        // Step 1: Play celebration sound immediately
        SoundManager.shared.playSwipeRight()
        
        // Step 2: Show checkmark (0.15s delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCheckmark = true
            }
        }
        
        // Step 3: Show confetti (0.4s delay — after checkmark starts)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.2)) {
                showConfetti = true
            }
        }
        
        // Step 4: Trigger text + button animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateSuccess = true
        }
    }
}

// MARK: - Preview
#Preview {
    StudyCompletionView(
        selectedTab: .constant(1),
        onContinue: {},
        onRestart: {},
        showPackageSelection: .constant(false)
    )
}
