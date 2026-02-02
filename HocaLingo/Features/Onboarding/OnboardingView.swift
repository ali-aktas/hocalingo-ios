//
//  OnboardingView.swift
//  HocaLingo
//
//  ✅ FIXED: Background added
//  Location: HocaLingo/Features/Onboarding/OnboardingView.swift
//

import SwiftUI

// MARK: - Onboarding View (Main Container)
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        ZStack {
            // Content based on current step
            Group {
                switch viewModel.currentStep {
                case .introduction:
                    OnboardingScreen1View(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .userProfile:
                    OnboardingScreen2View(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .swipeDemo:
                    OnboardingScreen3View(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .studyDemo:
                    OnboardingScreen4View(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.currentStep)
            
            // Skip button (top right - except on last screen)
            if viewModel.currentStep != .studyDemo {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            viewModel.skipOnboarding()
                        }) {
                            Text("onboarding_button_skip")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                }
            }
            
            // Completion animation overlay
            if viewModel.showCompletionAnimation {
                completionOverlay
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onChange(of: viewModel.showCompletionAnimation) { _, newValue in
            if newValue {
                // Wait for animation, then dismiss onboarding
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
    
    // MARK: - Completion Overlay
    private var completionOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(Color(hex: "10B981"))
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: "10B981").opacity(0.4), radius: 20)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
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
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
