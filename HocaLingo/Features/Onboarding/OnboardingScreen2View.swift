//
//  OnboardingScreen2View.swift
//  HocaLingo
//
//  ✅ FIXED: Background, fonts, localization
//  Location: HocaLingo/Features/Onboarding/OnboardingScreen2View.swift
//

import SwiftUI

// MARK: - Onboarding Screen 2 (User Profile)
struct OnboardingScreen2View: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        ZStack {
            // Background (HomeView style)
            backgroundLayer
            
            VStack(spacing: 0) {
                Spacer().frame(height: 40)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 48) {
                        // Question 1: Learning Goal
                        VStack(spacing: 20) {
                            Text("onboarding_question1_title")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            HStack(spacing: 16) {
                                GoalOptionCard(
                                    emoji: "📘",
                                    title: "onboarding_goal_exam",
                                    isSelected: viewModel.onboardingData.learningGoal == .examFocused,
                                    onTap: {
                                        viewModel.selectLearningGoal(.examFocused)
                                    }
                                )
                                
                                GoalOptionCard(
                                    emoji: "🗣️",
                                    title: "onboarding_goal_conversation",
                                    isSelected: viewModel.onboardingData.learningGoal == .conversationFocused,
                                    onTap: {
                                        viewModel.selectLearningGoal(.conversationFocused)
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Question 2: English Level (show only after Q1 answered)
                        if viewModel.onboardingData.learningGoal != nil {
                            VStack(spacing: 20) {
                                Text("onboarding_question2_title")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    LevelOptionRow(
                                        title: "onboarding_level_beginner",
                                        isSelected: viewModel.onboardingData.englishLevel == .beginner,
                                        onTap: {
                                            viewModel.selectEnglishLevel(.beginner)
                                        }
                                    )
                                    
                                    LevelOptionRow(
                                        title: "onboarding_level_intermediate",
                                        isSelected: viewModel.onboardingData.englishLevel == .intermediate,
                                        onTap: {
                                            viewModel.selectEnglishLevel(.intermediate)
                                        }
                                    )
                                    
                                    LevelOptionRow(
                                        title: "onboarding_level_advanced",
                                        isSelected: viewModel.onboardingData.englishLevel == .advanced,
                                        onTap: {
                                            viewModel.selectEnglishLevel(.advanced)
                                        }
                                    )
                                }
                                .padding(.horizontal, 24)
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                Spacer()
                
                // Bottom area
                VStack(spacing: 16) {
                    // Progress indicator
                    ProgressIndicator(
                        currentStep: viewModel.currentStep.progressValue,
                        totalSteps: viewModel.currentStep.totalSteps
                    )
                    
                    // Continue button
                    OnboardingButton(
                        title: "onboarding_button_next",
                        isEnabled: viewModel.canProceed
                    ) {
                        viewModel.nextStep()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Background Layer
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

// MARK: - Goal Option Card
private struct GoalOptionCard: View {
    let emoji: String
    let title: LocalizedStringKey
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 48))
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color(hex: "4ECDC4") : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color(hex: "4ECDC4") : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "4ECDC4").opacity(0.3) : .clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .buttonStyle(OnboardingScaleButtonStyle())
    }
}

// MARK: - Level Option Row
private struct LevelOptionRow: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: "4ECDC4") : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(hex: "4ECDC4") : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(OnboardingScaleButtonStyle())
    }
}

// MARK: - Onboarding Scale Button Style
private struct OnboardingScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    OnboardingScreen2View(viewModel: OnboardingViewModel())
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
