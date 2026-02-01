//
//  AIStoryViewModel.swift
//  HocaLingo
//
//  Features/AIStory/ViewModels/AIStoryViewModel.swift
//  ✅ FULLY FIXED: Kelime yükleme basitleştirildi, error handling düzeltildi
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
        
        // ✅ Observe premium status
        observePremiumStatus()
    }
    
    // MARK: - ✅ Premium Status Observer
    
    private func observePremiumStatus() {
        PremiumManager.shared.$isPremium
            .sink { [weak self] isPremium in
                self?.uiState.isPremium = isPremium
                self?.refreshQuota()
            }
            .store(in: &cancellables)
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
        // Close creator sheet FIRST
        uiState.showCreator = false
        
        // Wait for sheet to dismiss
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        // Start generation
        uiState.isGenerating = true
        uiState.error = nil
        
        // Animate phases
        Task {
            await animatePhases()
        }
        
        do {
            // Get API key
            let apiKey = try Config.getGeminiAPIKey()
            
            print("🚀 Starting story generation...")
            print("   - Words: \(uiState.allWords.count)")
            print("   - Type: \(uiState.creatorType)")
            print("   - Length: \(uiState.creatorLength)")
            
            // Generate story
            let story = try await repository.generateStory(
                topic: uiState.creatorTopic.isEmpty ? nil : uiState.creatorTopic,
                type: uiState.creatorType,
                length: uiState.creatorLength,
                allWords: uiState.allWords,
                isPremium: uiState.isPremium,
                apiKey: apiKey
            )
            
            print("✅ Story generated successfully!")
            
            // Success
            handle(.generationCompleted(story))
            
        } catch {
            // Error
            print("❌ Story generation failed: \(error)")
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
        uiState.isPremium = PremiumManager.shared.isPremium
        
        // Load quota
        refreshQuota()
        
        // Load words
        loadWords()
        
        // Load stories
        loadStories()
        
        uiState.isLoading = false
    }
    
    private func refreshQuota() {
        let quotaManager = QuotaManager()
        uiState.quota = quotaManager.getCurrentQuota(isPremium: uiState.isPremium)
    }
    
    /// ✅ COMPLETELY REWRITTEN: Sadece seçili kelimeleri UserDefaults'tan yükle
    private func loadWords() {
        print("🔍 Loading words for AI Story...")
        
        // 1. Seçili kelime ID'lerini al
        let selectedWordIds = Set(userDefaults.loadSelectedWords())
        print("📝 Found \(selectedWordIds.count) selected word IDs")
        
        guard !selectedWordIds.isEmpty else {
            print("⚠️ No selected words found")
            uiState.allWords = []
            return
        }
        
        // 2. Kelimeleri yükle (UserDefaults'ta Word objesi olarak saklanıyor)
        // NOT: Kelimeler global olarak saklanıyor, paket bazlı değil!
        var allWords: [Word] = []
        
        // User-added words
        let userWords = userDefaults.loadUserAddedWords()
        allWords.append(contentsOf: userWords.filter { selectedWordIds.contains($0.id) })
        print("👤 Loaded \(userWords.filter { selectedWordIds.contains($0.id) }.count) user-added words")
        
        // Package words - sadece A1 paketi var şu an
        if let url = Bundle.main.url(forResource: "standard_a1_001", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let package = try? JSONDecoder().decode(VocabularyPackage.self, from: data) {
            let packageWords = package.words.filter { selectedWordIds.contains($0.id) }
            allWords.append(contentsOf: packageWords)
            print("📦 Loaded \(packageWords.count) words from standard_a1_001")
        }
        
        uiState.allWords = allWords
        print("✅ Total loaded \(allWords.count) words for AI Story")
        
        // DEBUG: Print progress info
        let direction = userDefaults.loadStudyDirection()
        let eligibleCount = allWords.filter { word in
            guard let progress = userDefaults.loadProgress(for: word.id, direction: direction) else {
                return false
            }
            return !progress.learningPhase && progress.intervalDays < 21.0
        }.count
        print("📊 Eligible words (progress < 21 days): \(eligibleCount)/\(allWords.count)")
    }
    
    private func loadStories() {
        uiState.stories = repository.getAllStories()
    }
}
