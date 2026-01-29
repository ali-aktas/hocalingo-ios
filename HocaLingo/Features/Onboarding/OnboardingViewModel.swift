//
//  OnboardingViewModel.swift
//  HocaLingo
//
//  Onboarding flow manager - Handles navigation, user selections, and persistence
//  Location: HocaLingo/Features/Onboarding/OnboardingViewModel.swift
//
import SwiftUI
import Combine

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentStep: OnboardingStep = .introduction
    @Published var onboardingData = OnboardingData()
    @Published var showCompletionAnimation = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Navigation Control
    
    /// Move to next screen
    func nextStep() {
        switch currentStep {
        case .introduction:
            currentStep = .userProfile
        case .userProfile:
            // Only proceed if both questions answered
            guard onboardingData.learningGoal != nil,
                  onboardingData.englishLevel != nil else {
                return
            }
            currentStep = .swipeDemo
        case .swipeDemo:
            currentStep = .studyDemo
        case .studyDemo:
            // Final step - complete onboarding
            completeOnboarding()
        }
    }
    
    /// Go back to previous screen
    func previousStep() {
        switch currentStep {
        case .introduction:
            break // Can't go back from first screen
        case .userProfile:
            currentStep = .introduction
        case .swipeDemo:
            currentStep = .userProfile
        case .studyDemo:
            currentStep = .swipeDemo
        }
    }
    
    /// Skip onboarding (can be called from any screen)
    func skipOnboarding() {
        // Save minimal default data
        onboardingData.learningGoal = .examFocused  // Default
        onboardingData.englishLevel = .intermediate  // Default
        completeOnboarding()
    }
    
    // MARK: - User Selection Handlers
    
    func selectLearningGoal(_ goal: LearningGoal) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.learningGoal = goal
        }
    }
    
    func selectEnglishLevel(_ level: EnglishLevel) {
        withAnimation(.spring(response: 0.3)) {
            onboardingData.englishLevel = level
        }
    }
    
    // MARK: - Completion
    
    private func completeOnboarding() {
        // Save user preferences
        saveOnboardingData()
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Show completion animation
        withAnimation(.spring(response: 0.4)) {
            showCompletionAnimation = true
        }
        
        print("✅ Onboarding completed")
        print("   - Learning Goal: \(onboardingData.learningGoal?.rawValue ?? "none")")
        print("   - English Level: \(onboardingData.englishLevel?.rawValue ?? "none")")
    }
    
    // MARK: - Data Persistence
    
    private func saveOnboardingData() {
        if let goal = onboardingData.learningGoal {
            UserDefaults.standard.set(goal.rawValue, forKey: "userLearningGoal")
        }
        
        if let level = onboardingData.englishLevel {
            UserDefaults.standard.set(level.rawValue, forKey: "userEnglishLevel")
        }
    }
    
    // MARK: - Helpers
    
    var canProceed: Bool {
        switch currentStep {
        case .introduction:
            return true
        case .userProfile:
            return onboardingData.learningGoal != nil && onboardingData.englishLevel != nil
        case .swipeDemo, .studyDemo:
            return true
        }
    }
}
