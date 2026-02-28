//
//  OnboardingModels.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Premium onboarding flow models
//  5-step flow: Promise → Empathy → Goal → Level → Summary
//  Location: HocaLingo/Models/OnboardingModels.swift
//

import Foundation

// MARK: - Onboarding Step
/// Navigation control for the 5-screen onboarding flow
enum OnboardingStep: Int, CaseIterable {
    case promise = 0    // Screen 1: Welcome + mascot + brand promise
    case empathy = 1    // Screen 2: "Which describes you?" (emotional hook)
    case goal = 2       // Screen 3: Study direction (Understand / Speak)
    case level = 3      // Screen 4: English level (4 options → package mapping)
    case summary = 4    // Screen 5: Personalized summary + launch

    var progressIndex: Int { rawValue }
    static var totalSteps: Int { allCases.count }
}

// MARK: - Empathy Choice
/// User's self-identified learning struggle (Screen 2)
enum EmpathyChoice: String, Codable, CaseIterable {
    case quitter = "quitter"           // "Başlayıp bırakıyorum"
    case forgetful = "forgetful"       // "Kelimeler aklımda kalmıyor"
    case noTime = "no_time"            // "Zamanım hiç yok"

    var iconName: String {
        switch self {
        case .quitter:   return "flame.fill"
        case .forgetful: return "brain.head.profile"
        case .noTime:    return "clock.fill"
        }
    }

    var iconColor: String {
        switch self {
        case .quitter:   return "FF6B6B"
        case .forgetful: return "845EF7"
        case .noTime:    return "FFA94D"
        }
    }
}

// MARK: - Learning Goal (maps to StudyDirection)
/// User's primary learning objective → determines default StudyDirection
enum LearningGoal: String, Codable, CaseIterable {
    case understand = "understand"       // EN → TR (reading, listening, exams)
    case speak = "speak"                 // TR → EN (speaking, recall)
}

// MARK: - English Level (4 tiers with package mapping)
/// User's self-assessed level → maps to a default vocabulary package
enum EnglishLevel: String, Codable, CaseIterable {
    case beginner = "beginner"                 // A1-A2
    case intermediate = "intermediate"         // B1
    case upperIntermediate = "upper_intermediate" // B2
    case advanced = "advanced"                 // C1

    /// Maps level to the default package ID for post-onboarding word selection
    var defaultPackageId: String {
        switch self {
        case .beginner:          return "standard_a1_001"
        case .intermediate:      return "standard_b1_001"
        case .upperIntermediate: return "standard_b2_001"
        case .advanced:          return "standard_c1_001"
        }
    }

    /// SF Symbol for the level card
    var iconName: String {
        switch self {
        case .beginner:          return "leaf.fill"
        case .intermediate:      return "book.fill"
        case .upperIntermediate: return "briefcase.fill"
        case .advanced:          return "star.fill"
        }
    }

    var iconColor: String {
        switch self {
        case .beginner:          return "4ECDC4"
        case .intermediate:      return "6366F1"
        case .upperIntermediate: return "F59E0B"
        case .advanced:          return "EF4444"
        }
    }
}

// MARK: - Onboarding Data
/// Collected user selections during the onboarding flow
struct OnboardingData: Codable {
    var empathyChoice: EmpathyChoice?
    var learningGoal: LearningGoal?
    var englishLevel: EnglishLevel?
    var isCompleted: Bool = false

    var isReadyToComplete: Bool {
        return learningGoal != nil && englishLevel != nil
    }
}
