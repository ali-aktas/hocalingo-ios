//
//  AIStoryUIState.swift
//  HocaLingo
//
//  Features/AIStory/ViewModels/AIStoryUIState.swift
//  MVI Pattern - UI State & Events
//

import Foundation

// MARK: - UI State

/// Complete UI state for AI Story feature
struct AIStoryUIState {
    // User & Quota
    var isPremium: Bool = false
    var quota: StoryQuota = StoryQuota.current(isPremium: false)
    
    // Data
    var allWords: [Word] = []
    var stories: [GeneratedStory] = []
    var currentStory: GeneratedStory? = nil
    
    // Loading States
    var isLoading: Bool = false
    var isGenerating: Bool = false
    var generatingPhase: GeneratingPhase = .collectingWords
    
    // UI States
    var showCreator: Bool = false
    var showHistory: Bool = false
    var showDetail: Bool = false
    var error: AIStoryError? = nil
    
    // Creator Form
    var creatorTopic: String = ""
    var creatorType: StoryType = .motivation
    var creatorLength: StoryLength = .short
    
    // Computed Properties
    var hasQuota: Bool {
        quota.hasQuota
    }
    
    var canGenerate: Bool {
        !isGenerating && hasQuota && allWords.count >= creatorLength.minDeckWords
    }
    
    var quotaDisplayText: String {
        "\(quota.remaining)/\(quota.limit)"
    }
}

// MARK: - Events

/// User actions and system events
enum AIStoryEvent {
    // Navigation
    case openCreator
    case closeCreator
    case openHistory
    case closeHistory
    case openDetail(GeneratedStory)
    case closeDetail
    
    // Story Generation
    case generateStory
    case generationCompleted(GeneratedStory)
    case generationFailed(AIStoryError)
    
    // Story Management
    case toggleFavorite(String)  // story ID
    case deleteStory(String)     // story ID
    
    // Creator Form
    case updateTopic(String)
    case selectType(StoryType)
    case selectLength(StoryLength)
    
    // Data Loading
    case loadData
    case refreshQuota
}

// MARK: - Generating Phases

/// Animation phases during story generation
enum GeneratingPhase: Equatable {
    case collectingWords
    case writingStory
    case finalTouches
    
    var icon: String {
        switch self {
        case .collectingWords: return "magnifyingglass"
        case .writingStory: return "pencil"
        case .finalTouches: return "sparkles"
        }
    }
    
    var title: String {
        switch self {
        case .collectingWords: return "collecting_words"
        case .writingStory: return "writing_story"
        case .finalTouches: return "final_touches"
        }
    }
    
    /// Duration for each phase (in seconds)
    var duration: Double {
        switch self {
        case .collectingWords: return 1.5
        case .writingStory: return 2.0
        case .finalTouches: return 1.0
        }
    }
}
