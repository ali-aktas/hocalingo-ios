//
//  OnboardingScreen1View.swift
//  HocaLingo
//
//  ✅ FIXED: Image name, size, fonts, slogan, background
//  Location: HocaLingo/Features/Onboarding/OnboardingScreen1View.swift
//

import SwiftUI

// MARK: - Onboarding Screen 1 (Introduction)
struct OnboardingScreen1View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        ZStack {
            // Background (HomeView style)
            backgroundLayer
            
            VStack(spacing: 0) {
                Spacer()
                
                // Mascot image (20% bigger)
                Image("lingohoca1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 260, height: 260)
                    .padding(.bottom, 32)
                
                // Main message (better font + line break after comma)
                VStack(spacing: 16) {
                    Text("Dünyanın en basit İngilizce öğrenme metoduna hazır mısın?")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .lineSpacing(4)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Bottom area
                VStack(spacing: 16) {
                    // Progress indicator
                    ProgressIndicator(
                        currentStep: viewModel.currentStep.progressValue,
                        totalSteps: viewModel.currentStep.totalSteps
                    )
                    
                    // Continue button (✅ FIXED: LocalizedStringKey)
                    OnboardingButton(title: LocalizedStringKey("onboarding_button_next")) {
                        viewModel.nextStep()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Background Layer (HomeView style)
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hex: "1A1625"),
                    Color(hex: "211A2E")
                ] : [
                    Color(hex: "FBF2FF"),
                    Color(hex: "FAF1FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
        }
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Preview
#Preview {
    OnboardingScreen1View(viewModel: OnboardingViewModel())
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
