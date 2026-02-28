//
//  OnboardingViewModel.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Premium 5-step onboarding flow manager
//  Handles navigation, selections, persistence, and post-onboarding routing
//  Location: HocaLingo/Features/Onboarding/OnboardingViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .promise
    @Published var onboardingData = OnboardingData()
    @Published var showCompletionAnimation = false
    @Published var mascotMessage: LocalizedStringKey? = nil

    // MARK: - Private
    private let userDefaults = UserDefaultsManager.shared

    // MARK: - Computed
    var canProceed: Bool {
        switch currentStep {
        case .promise:  return true
        case .empathy:  return onboardingData.empathyChoice != nil
        case .goal:     return onboardingData.learningGoal != nil
        case .level:    return onboardingData.englishLevel != nil
        case .summary:  return true
        }
    }

    // MARK: - Navigation

    func nextStep() {
        guard canProceed else { return }

        switch currentStep {
        case .promise:
            currentStep = .empathy
        case .empathy:
            currentStep = .goal
        case .goal:
            currentStep = .level
        case .level:
            currentStep = .summary
        case .summary:
            completeOnboarding()
        }
    }

    func skipOnboarding() {
        // Set safe defaults
        onboardingData.empathyChoice = .forgetful
        onboardingData.learningGoal = .understand
        onboardingData.englishLevel = .intermediate
        completeOnboarding()
    }

    // MARK: - Selection Handlers

    func selectEmpathy(_ choice: EmpathyChoice) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.empathyChoice = choice
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Show mascot response after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4)) {
                self.mascotMessage = "onboarding_empathy_response"
            }
        }
    }

    func selectGoal(_ goal: LearningGoal) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.learningGoal = goal
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func selectLevel(_ level: EnglishLevel) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.englishLevel = level
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Show mascot message based on level
        let key: LocalizedStringKey
        switch level {
        case .beginner:          key = "onboarding_level_response_beginner"
        case .intermediate:      key = "onboarding_level_response_intermediate"
        case .upperIntermediate: key = "onboarding_level_response_upper"
        case .advanced:          key = "onboarding_level_response_advanced"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4)) {
                self.mascotMessage = key
            }
        }
    }

    /// Clear mascot message when moving to next step
    func clearMascotMessage() {
        mascotMessage = nil
    }

    // MARK: - Completion

    private func completeOnboarding() {
        saveOnboardingData()

        // Mark completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Trigger completion animation
        withAnimation(.spring(response: 0.4)) {
            showCompletionAnimation = true
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        print("✅ Onboarding completed")
        print("   - Empathy: \(onboardingData.empathyChoice?.rawValue ?? "none")")
        print("   - Goal: \(onboardingData.learningGoal?.rawValue ?? "none")")
        print("   - Level: \(onboardingData.englishLevel?.rawValue ?? "none")")
        print("   - Package: \(onboardingData.englishLevel?.defaultPackageId ?? "none")")
    }

    // MARK: - Persistence

    private func saveOnboardingData() {
        // Save study direction based on goal
        if let goal = onboardingData.learningGoal {
            let direction: StudyDirection = (goal == .understand) ? .enToTr : .trToEn
            userDefaults.saveStudyDirection(direction)
            print("   → Study direction saved: \(direction.rawValue)")
        }

        // Save selected package based on level
        if let level = onboardingData.englishLevel {
            userDefaults.saveSelectedPackage(level.defaultPackageId)
            print("   → Default package saved: \(level.defaultPackageId)")
        }

        // Save full onboarding data as JSON
        onboardingData.isCompleted = true
        if let encoded = try? JSONEncoder().encode(onboardingData) {
            UserDefaults.standard.set(encoded, forKey: "onboardingData")
        }
    }

    /// Load saved onboarding data (for summary screen or later use)
    static func loadSavedData() -> OnboardingData? {
        guard let data = UserDefaults.standard.data(forKey: "onboardingData"),
              let decoded = try? JSONDecoder().decode(OnboardingData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
