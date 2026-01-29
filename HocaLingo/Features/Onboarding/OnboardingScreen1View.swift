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
                    Text("İngilizce öğrenmenin en iyi yolu hızlı tekrarlı kelime öğrenmektir..")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Kelime öğrenmenin en iyi yolu ise HocaLingo kullanmaktır!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
            Color.themeBackground
                .ignoresSafeArea()
            
            // Purple flow (top right corner)
            Circle()
                .fill(Color.themePrimaryButton.opacity(themeViewModel.isDarkMode(in: colorScheme) ? 0.12 : 0.05))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingScreen1View(viewModel: OnboardingViewModel())
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
