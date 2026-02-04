//
//  StoryRepository.swift
//  HocaLingo
//
//  Core/Storage/StoryRepository.swift
//  ✅ UPDATED: Extract actually used words from content
//  Location: HocaLingo/Core/Storage/StoryRepository.swift
//

import Foundation

/// Story repository - Main business logic
/// Coordinates all story generation operations
class StoryRepository {
    
    // MARK: - Dependencies
    
    private let apiService: GeminiAPIService
    private let wordSelector: WordSelector
    private let promptBuilder: PromptBuilder
    private let contentCleaner: ContentCleaner
    private let quotaManager: QuotaManager
    
    // MARK: - Storage
    
    private let storageKey = "generated_stories"
    private let maxStoredStories = 30  // Keep last 30 stories
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    init(
        apiService: GeminiAPIService = GeminiAPIService(),
        wordSelector: WordSelector = WordSelector(),
        promptBuilder: PromptBuilder = PromptBuilder(),
        contentCleaner: ContentCleaner = ContentCleaner(),
        quotaManager: QuotaManager = QuotaManager()
    ) {
        self.apiService = apiService
        self.wordSelector = wordSelector
        self.promptBuilder = promptBuilder
        self.contentCleaner = contentCleaner
        self.quotaManager = quotaManager
    }
    
    // MARK: - Story Generation
    
    /// Generate new story with AI
    /// Main workflow: quota → select words → build prompt → API call → clean → save
    /// ✅ UPDATED: Extract actually used words (whole-word matching)
    /// - Parameters:
    ///   - topic: Optional topic/theme
    ///   - type: Story type (motivation, fantasy, dialogue)
    ///   - length: Story length (short, long)
    ///   - allWords: User's complete vocabulary
    ///   - isPremium: Premium status
    ///   - apiKey: Gemini API key
    /// - Returns: Generated story
    /// - Throws: AIStoryError for various failure scenarios
    func generateStory(
        topic: String?,
        type: StoryType,
        length: StoryLength,
        allWords: [Word],
        isPremium: Bool,
        apiKey: String
    ) async throws -> GeneratedStory {
        
        // STEP 1: Check quota
        let quota = quotaManager.getCurrentQuota(isPremium: isPremium)
        guard quota.hasQuota else {
            throw AIStoryError.quotaExceeded(
                remaining: quota.remaining,
                limit: quota.limit
            )
        }
        
        // STEP 2: Select words from vocabulary
        // ✅ Now returns EXACT 20 or 40 words
        let selectedWords = try wordSelector.selectWords(
            from: allWords,
            for: length
        )
        
        print("📝 Selected \(selectedWords.count) words for story generation")
        
        // STEP 3: Build AI prompt
        let prompt = promptBuilder.buildPrompt(
            words: selectedWords,
            topic: topic,
            type: type,
            length: length
        )
        
        // STEP 4: Create API request
        let request = GeminiRequest.create(
            prompt: prompt,
            maxTokens: length.maxTokens
        )
        
        // STEP 5: Call Gemini API
        let response = try await apiService.generateStory(
            apiKey: apiKey,
            request: request
        )
        
        // STEP 6: Extract raw text
        let rawText = response.getGeneratedText()
        guard !rawText.isEmpty else {
            throw AIStoryError.emptyResponse
        }
        
        // STEP 7: Clean content and extract title
        let (title, content) = contentCleaner.clean(rawText)
        
        // ✅ STEP 8: Extract actually used words (NEW!)
        // This fixes the "Senin Kelimelerin" bug where all candidate words were shown
        let actuallyUsedWords = GeneratedStory.extractUsedWords(
            from: content,
            candidateWords: selectedWords
        )
        
        print("✅ AI used \(actuallyUsedWords.count)/\(selectedWords.count) words")
        
        // Debug: Show which words were NOT used
        let unusedWords = selectedWords.filter { candidate in
            !actuallyUsedWords.contains(where: { $0.id == candidate.id })
        }
        if !unusedWords.isEmpty {
            print("⚠️ Unused words: \(unusedWords.map { $0.english }.joined(separator: ", "))")
        }
        
        // STEP 9: Create story object
        let story = GeneratedStory(
            title: title,
            content: content,
            usedWordIds: actuallyUsedWords.map { $0.id },  // ✅ Only actually used IDs
            usedWords: actuallyUsedWords,                  // ✅ Only actually used words
            topic: topic,
            type: type,
            length: length,
            createdAt: Date(),
            isFavorite: false
        )
        
        // STEP 10: Save story
        try saveStory(story)
        
        // STEP 11: Increment quota
        try quotaManager.incrementQuota(isPremium: isPremium)
        
        return story
    }
    
    // MARK: - Story CRUD
    
    /// Get all saved stories (newest first)
    /// - Returns: Array of stories, limited to last 30
    func getAllStories() -> [GeneratedStory] {
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        let stories = (try? decoder.decode([GeneratedStory].self, from: data)) ?? []
        
        return stories.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// Get story by ID
    /// - Parameter id: Story ID
    /// - Returns: Story if found
    func getStory(by id: String) -> GeneratedStory? {
        return getAllStories().first { $0.id == id }
    }
    
    /// Save story to storage
    /// - Parameter story: Story to save
    /// - Throws: AIStoryError.saveFailed if encoding fails
    private func saveStory(_ story: GeneratedStory) throws {
        var stories = getAllStories()
        
        // Add new story at beginning
        stories.insert(story, at: 0)
        
        // Keep only last 30 stories
        if stories.count > maxStoredStories {
            stories = Array(stories.prefix(maxStoredStories))
        }
        
        // Encode and save
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(stories) else {
            throw AIStoryError.saveFailed
        }
        
        defaults.set(data, forKey: storageKey)
    }
    
    // MARK: - Quota Operations
    
    /// Get current quota info
    /// - Parameter isPremium: Premium status
    /// - Returns: (used, total) tuple
    func getQuotaInfo(isPremium: Bool) -> (used: Int, total: Int) {
        return quotaManager.getQuotaInfo(isPremium: isPremium)
    }
    
    /// Check if user can generate story
    /// - Parameter isPremium: Premium status
    /// - Returns: Boolean indicating availability
    func canGenerateStory(isPremium: Bool) -> Bool {
        return quotaManager.canGenerateStory(isPremium: isPremium)
    }
    
    /// Get remaining stories count
    /// - Parameter isPremium: Premium status
    /// - Returns: Number of remaining stories
    func remainingStories(isPremium: Bool) -> Int {
        return quotaManager.remainingStories(isPremium: isPremium)
    }
    
    // MARK: - Statistics
    
    /// Get total stories count
    func totalStoriesCount() -> Int {
        return getAllStories().count
    }
    
    /// Get favorites count
    func favoritesCount() -> Int {
        return getAllStories().filter { $0.isFavorite }.count
    }
    
    /// Get stories by type
    func getStories(by type: StoryType) -> [GeneratedStory] {
        return getAllStories().filter { $0.type == type }
    }
    
    /// Toggle favorite status
    /// - Parameter id: Story ID
    /// - Throws: AIStoryError.saveFailed if not found
    func toggleFavorite(id: String) throws {
        var stories = getAllStories()
        
        guard let index = stories.firstIndex(where: { $0.id == id }) else {
            throw AIStoryError.saveFailed
        }
        
        stories[index].isFavorite.toggle()
        
        // Save updated list
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(stories) else {
            throw AIStoryError.saveFailed
        }
        
        defaults.set(data, forKey: storageKey)
    }
    
    /// Delete story
    /// - Parameter id: Story ID
    /// - Throws: AIStoryError.deleteFailed if not found
    func deleteStory(id: String) throws {
        var stories = getAllStories()
        
        guard let index = stories.firstIndex(where: { $0.id == id }) else {
            throw AIStoryError.deleteFailed
        }
        
        stories.remove(at: index)
        
        // Save updated list
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(stories) else {
            throw AIStoryError.deleteFailed
        }
        
        defaults.set(data, forKey: storageKey)
    }
    
    /// Clear all stories (for testing/reset)
    func clearAllStories() {
        defaults.removeObject(forKey: storageKey)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension StoryRepository {
    /// Get debug info
    func debugInfo(isPremium: Bool) -> String {
        let stories = getAllStories()
        let quota = quotaManager.getCurrentQuota(isPremium: isPremium)
        
        return """
        === Story Repository Debug ===
        Total Stories: \(stories.count)
        Favorites: \(favoritesCount())
        Quota: \(quota.usedCount)/\(quota.limit)
        Remaining: \(quota.remaining)
        """
    }
}
#endif
