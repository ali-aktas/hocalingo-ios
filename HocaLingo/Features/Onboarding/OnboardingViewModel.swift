//
//  OnboardingViewModel.swift
//  HocaLingo
//
//  ✅ V2: Back navigation + personalized empathy/goal responses
//  ✅ V2: isMovingBack flag for bidirectional screen transitions
//  ✅ V2: Success sound moved to SummaryScreen entry (plays with confetti)
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
    
    // ✅ NEW: Tracks navigation direction for transition animation
    // true  = user tapped back → slide from leading edge
    // false = user tapped forward → slide from trailing edge (default)
    @Published var isMovingBack: Bool = false

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
    
    /// ✅ NEW: Whether back navigation is allowed from the current step
    var canGoBack: Bool {
        currentStep != .promise && currentStep != .summary
    }

    // MARK: - Navigation

    func nextStep() {
        guard canProceed else { return }
        isMovingBack = false  // Ensure forward transition direction

        switch currentStep {
        case .promise:
            MetaEventManager.shared.logOnboardingStart()
            MixpanelManager.shared.trackOnboardingStarted()
            currentStep = .empathy
        case .empathy:
            currentStep = .goal
            MixpanelManager.shared.trackOnboardingStepCompleted(step: "empathy", selection: onboardingData.empathyChoice?.rawValue)
        case .goal:
            currentStep = .level
            MixpanelManager.shared.trackOnboardingStepCompleted(step: "goal", selection: onboardingData.learningGoal?.rawValue)
        case .level:
            currentStep = .summary
            MixpanelManager.shared.trackOnboardingStepCompleted(step: "level", selection: onboardingData.englishLevel?.rawValue)
        case .summary:
            completeOnboarding()
        }
    }
    
    /// ✅ NEW: Navigate back one step (screens 2-4 only)
    /// Clears mascot message and reverses transition direction
    func previousStep() {
        guard canGoBack else { return }
        
        // Set direction flag so OnboardingView uses backward transition
        isMovingBack = true
        
        // Clear mascot speech bubble before transitioning out
        mascotMessage = nil
        
        switch currentStep {
        case .promise:
            break  // No previous screen
        case .empathy:
            currentStep = .promise
        case .goal:
            currentStep = .empathy
        case .level:
            currentStep = .goal
        case .summary:
            currentStep = .level
        }
        
        // Reset flag after transition animation completes (~0.45s + buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.isMovingBack = false
        }
    }

    func skipOnboarding() {
        // Set safe defaults
        onboardingData.empathyChoice = .forgetful
        onboardingData.learningGoal = .understand
        onboardingData.englishLevel = .intermediate
        MixpanelManager.shared.trackOnboardingSkipped(atStep: currentStep.rawValue.description)
        completeOnboarding()
    }

    // MARK: - Selection Handlers

    /// ✅ UPDATED: Personalized mascot response per empathy choice
    func selectEmpathy(_ choice: EmpathyChoice) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.empathyChoice = choice
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Map each choice to its own warm, empathic response
        let key: LocalizedStringKey
        switch choice {
        case .quitter:   key = "onboarding_empathy_response_quitter"
        case .forgetful: key = "onboarding_empathy_response_forgetful"
        case .noTime:    key = "onboarding_empathy_response_no_time"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            withAnimation(.spring(response: 0.4)) {
                self?.mascotMessage = key
            }
        }
    }

    /// ✅ UPDATED: Added mascot response (was silent before)
    func selectGoal(_ goal: LearningGoal) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.learningGoal = goal
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Map each goal to its own mascot encouragement
        let key: LocalizedStringKey
        switch goal {
        case .understand: key = "onboarding_goal_response_understand"
        case .speak:      key = "onboarding_goal_response_speak"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            withAnimation(.spring(response: 0.4)) {
                self?.mascotMessage = key
            }
        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            withAnimation(.spring(response: 0.4)) {
                self?.mascotMessage = key
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
        
        // Meta Events
        MetaEventManager.shared.logOnboardingCompleted()
        if let level = onboardingData.englishLevel {
            MetaEventManager.shared.logOnboardingLevelSelected(level: level.rawValue)
        }

        // Mark completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // Trigger completion animation
        // Note: Success sound plays earlier on SummaryScreen entry (synced with confetti)
        withAnimation(.spring(response: 0.4)) {
            showCompletionAnimation = true
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        print("✅ Onboarding completed")
        print("   - Empathy: \(onboardingData.empathyChoice?.rawValue ?? "none")")
        print("   - Goal: \(onboardingData.learningGoal?.rawValue ?? "none")")
        print("   - Level: \(onboardingData.englishLevel?.rawValue ?? "none")")
    }

    private func saveOnboardingData() {
        // Save empathy (optional — for analytics/personalization)
        if let empathy = onboardingData.empathyChoice {
            UserDefaults.standard.set(empathy.rawValue, forKey: "onboarding_empathy")
        }

        // Save study direction (goal → direction mapping)
        if let goal = onboardingData.learningGoal {
            let direction: StudyDirection = goal == .speak ? .trToEn : .enToTr
            userDefaults.saveStudyDirection(direction)
        }

        // Save English level (optional — for package suggestion)
        if let level = onboardingData.englishLevel {
            UserDefaults.standard.set(level.rawValue, forKey: "onboarding_english_level")
        }
    }
}
