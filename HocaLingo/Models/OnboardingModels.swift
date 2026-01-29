//
//  OnboardingModels.swift
//  HocaLingo
//
//  Onboarding data models - User preferences and flow control
//  Location: HocaLingo/Models/OnboardingModels.swift
//

import Foundation

// MARK: - Learning Goal
/// User's primary learning objective
enum LearningGoal: String, Codable, CaseIterable {
    case examFocused = "exam_focused"
    case conversationFocused = "conversation_focused"
    
    var emoji: String {
        switch self {
        case .examFocused: return "📘"
        case .conversationFocused: return "🗣️"
        }
    }
}

// MARK: - English Level
/// User's current English proficiency level
enum EnglishLevel: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
}

// MARK: - Onboarding Step
/// Navigation control for onboarding screens
enum OnboardingStep: Int {
    case introduction = 0  // Screen 1: Welcome + mascot
    case userProfile = 1   // Screen 2: 2 questions
    case swipeDemo = 2     // Screen 3: Swipe demo
    case studyDemo = 3     // Screen 4: Flip + difficulty demo
    
    var progressValue: Int {
        return rawValue + 1  // 1, 2, 3, 4
    }
    
    var totalSteps: Int {
        return 4
    }
}

// MARK: - Onboarding Data
/// User selections during onboarding
struct OnboardingData: Codable {
    var learningGoal: LearningGoal?
    var englishLevel: EnglishLevel?
    var isCompleted: Bool = false
    
    var isReadyToComplete: Bool {
        return learningGoal != nil && englishLevel != nil
    }
}
