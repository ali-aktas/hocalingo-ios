//
//  AIStoryViewModel.swift
//  HocaLingo
//
//  Features/AIStory/ViewModels/AIStoryViewModel.swift
//  MVI Pattern - ViewModel with business logic
//

import Foundation
import Combine

/// AI Story ViewModel - Manages state and business logic
@MainActor
class AIStoryViewModel: ObservableObject {
    
    // MARK: - Published State
    
    @Published var uiState = AIStoryUIState()
    
    // MARK: - Dependencies
    
    private let repository: StoryRepository
    private let userDefaults: UserDefaultsManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        repository: StoryRepository = StoryRepository(),
        userDefaults: UserDefaultsManager = UserDefaultsManager.shared
    ) {
        self.repository = repository
        self.userDefaults = userDefaults
    }
    
    // MARK: - Event Handler
    
    func handle(_ event: AIStoryEvent) {
        switch event {
        // Navigation
        case .openCreator:
            handleOpenCreator()
        case .closeCreator:
            handleCloseCreator()
        case .openHistory:
            handleOpenHistory()
        case .closeHistory:
            handleCloseHistory()
        case .openDetail(let story):
            handleOpenDetail(story)
        case .closeDetail:
            handleCloseDetail()
            
        // Story Generation
        case .generateStory:
            Task { await handleGenerateStory() }
        case .generationCompleted(let story):
            handleGenerationCompleted(story)
        case .generationFailed(let error):
            handleGenerationFailed(error)
            
        // Story Management
        case .toggleFavorite(let id):
            handleToggleFavorite(id)
        case .deleteStory(let id):
            handleDeleteStory(id)
            
        // Creator Form
        case .updateTopic(let topic):
            uiState.creatorTopic = topic
        case .selectType(let type):
            uiState.creatorType = type
        case .selectLength(let length):
            uiState.creatorLength = length
            
        // Data Loading
        case .loadData:
            loadData()
        case .refreshQuota:
            refreshQuota()
        }
    }
    
    // MARK: - Navigation Handlers
    
    private func handleOpenCreator() {
        // Reset form
        uiState.creatorTopic = ""
        uiState.creatorType = .motivation
        uiState.creatorLength = .short
        uiState.error = nil
        uiState.showCreator = true
    }
    
    private func handleCloseCreator() {
        uiState.showCreator = false
    }
    
    private func handleOpenHistory() {
        uiState.showHistory = true
    }
    
    private func handleCloseHistory() {
        uiState.showHistory = false
    }
    
    private func handleOpenDetail(_ story: GeneratedStory) {
        uiState.currentStory = story
        uiState.showDetail = true
    }
    
    private func handleCloseDetail() {
        uiState.showDetail = false
        uiState.currentStory = nil
    }
    
    // MARK: - Story Generation
    
    private func handleGenerateStory() async {
        // Start generation
        uiState.isGenerating = true
        uiState.showCreator = false
        uiState.error = nil
        
        // Animate phases
        Task {
            await animatePhases()
        }
        
        do {
            // Get API key
            let apiKey = try Config.getGeminiAPIKey()
            
            // Get study direction
            let direction = userDefaults.loadStudyDirection()
            
            // Generate story
            let story = try await repository.generateStory(
                topic: uiState.creatorTopic.isEmpty ? nil : uiState.creatorTopic,
                type: uiState.creatorType,
                length: uiState.creatorLength,
                allWords: uiState.allWords,
                isPremium: uiState.isPremium,
                apiKey: apiKey
            )
            
            // Success
            handle(.generationCompleted(story))
            
        } catch {
            // Error
            if let storyError = error as? AIStoryError {
                handle(.generationFailed(storyError))
            } else {
                handle(.generationFailed(.unknown(error)))
            }
        }
    }
    
    private func animatePhases() async {
        // Phase 1: Collecting words
        uiState.generatingPhase = .collectingWords
        try? await Task.sleep(nanoseconds: UInt64(GeneratingPhase.collectingWords.duration * 1_000_000_000))
        
        // Phase 2: Writing story
        uiState.generatingPhase = .writingStory
        try? await Task.sleep(nanoseconds: UInt64(GeneratingPhase.writingStory.duration * 1_000_000_000))
        
        // Phase 3: Final touches
        uiState.generatingPhase = .finalTouches
        try? await Task.sleep(nanoseconds: UInt64(GeneratingPhase.finalTouches.duration * 1_000_000_000))
    }
    
    private func handleGenerationCompleted(_ story: GeneratedStory) {
        uiState.isGenerating = false
        uiState.stories.insert(story, at: 0)
        refreshQuota()
        
        // Auto-open detail
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.handle(.openDetail(story))
        }
    }
    
    private func handleGenerationFailed(_ error: AIStoryError) {
        uiState.isGenerating = false
        uiState.error = error
    }
    
    // MARK: - Story Management
    
    private func handleToggleFavorite(_ id: String) {
        do {
            try repository.toggleFavorite(id: id)
            loadStories()
        } catch {
            uiState.error = .saveFailed
        }
    }
    
    private func handleDeleteStory(_ id: String) {
        do {
            try repository.deleteStory(id: id)
            loadStories()
            
            // Close detail if deleted story is shown
            if uiState.currentStory?.id == id {
                handleCloseDetail()
            }
        } catch {
            uiState.error = .deleteFailed
        }
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        uiState.isLoading = true
        
        // Load premium status
        // TODO: Integrate with RevenueCat
        uiState.isPremium = false
        
        // Load quota
        refreshQuota()
        
        // Load words
        loadWords()
        
        // Load stories
        loadStories()
        
        uiState.isLoading = false
    }
    
    private func refreshQuota() {
        uiState.quota = repository.getQuotaInfo(isPremium: uiState.isPremium).0 == 0
            ? StoryQuota.current(isPremium: uiState.isPremium)
            : StoryQuota(
                month: Calendar.current.dateComponents([.year, .month], from: Date()).month.map { String(format: "%04d-%02d", Calendar.current.component(.year, from: Date()), $0) } ?? "",
                usedCount: repository.getQuotaInfo(isPremium: uiState.isPremium).0,
                resetDate: Date(),
                isPremium: uiState.isPremium
            )
    }
    
    private func loadWords() {
        // Load selected words
        let selectedWordIds = userDefaults.loadSelectedWords()
        
        // Load word details from packages
        var words: [Word] = []
        
        // Load standard packages
        for level in ["a1", "a2", "b1", "b2", "c1", "c2"] {
            let resourceName = "standard_\(level)_001"
            
            // Try to find JSON file
            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
                print("⚠️ Package file not found: \(resourceName).json")
                continue
            }
            
            // Try to load and decode
            guard let data = try? Data(contentsOf: url),
                  let packageWords = try? JSONDecoder().decode([Word].self, from: data) else {
                print("⚠️ Failed to decode package: \(resourceName).json")
                continue
            }
            
            // Add selected words from this package
            words.append(contentsOf: packageWords.filter { selectedWordIds.contains($0.id) })
        }
        
        // Load user-added words
        words.append(contentsOf: userDefaults.loadUserAddedWords())
        
        print("✅ Loaded \(words.count) words for AI Story")
        uiState.allWords = words
    }
    
    private func loadStories() {
        uiState.stories = repository.getAllStories()
    }
}
