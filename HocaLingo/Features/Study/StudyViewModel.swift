//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ CRITICAL FIX v3.1: Proper card requeuing based on difficulty
//  - HARD: Card goes to front (position + 1)
//  - MEDIUM: Card goes to middle (position + 5)
//  - EASY: Card goes to back (position + 10) or graduates
//  - Queue is RE-SORTED after each answer
//  - Graduated cards removed from queue
//  - Session continues smoothly until all cards graduate
//
//  Location: HocaLingo/Features/Study/StudyViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Card Difficulty
enum CardDifficulty {
    case hard
    case medium
    case easy
    
    var quality: Int {
        switch self {
        case .hard: return SpacedRepetition.QUALITY_HARD
        case .medium: return SpacedRepetition.QUALITY_MEDIUM
        case .easy: return SpacedRepetition.QUALITY_EASY
        }
    }
}

// MARK: - Study Card Model
struct StudyCard: Identifiable {
    let id: UUID
    let wordId: Int
    let frontText: String
    let backText: String
}

// MARK: - Card Colors (Android Parity - 20 vibrant colors)
private let studyCardColors: [Color] = [
    Color(hex: "6366F1"), Color(hex: "8B5CF6"), Color(hex: "EC4899"), Color(hex: "EF4444"),
    Color(hex: "F97316"), Color(hex: "10B981"), Color(hex: "06B6D4"), Color(hex: "3B82F6"),
    Color(hex: "8B5A2B"), Color(hex: "059669"), Color(hex: "7C3AED"), Color(hex: "DC2626"),
    Color(hex: "0891B2"), Color(hex: "065F46"), Color(hex: "7C2D12"), Color(hex: "1E40AF"),
    Color(hex: "7E22CE"), Color(hex: "0F766E"), Color(hex: "A21CAF"), Color(hex: "9A3412")
]

// MARK: - StudyViewModel
class StudyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCardIndex: Int = 0 {
        didSet {
            if currentCardIndex != oldValue && currentCardIndex < studyQueue.count {
                if studyDirection == .enToTr {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.playCurrentWordAudio()
                    }
                }
            }
        }
    }
    @Published var isCardFlipped: Bool = false
    @Published var studyQueue: [StudyCard] = []
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var shouldDismiss: Bool = false
    @Published var isSessionComplete: Bool = false
    @Published var cardsCompletedCount: Int = 0
    @Published var showNativeAd: Bool = false
    
    // MARK: - Dependencies
    private let userDefaults = UserDefaultsManager.shared
    private let jsonLoader = JSONLoader()
    private let soundManager = SoundManager.shared
    private let ttsManager = TTSManager.shared
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private var currentSessionMaxPosition: Int = 0
    private var ttsPlayedForCurrentCard: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        print("🎯 StudyViewModel init() called")
        observeDirectionChanges()
        observeWordsChanged()
        loadStudyQueue()
    }
    
    private func observeDirectionChanges() {
        NotificationCenter.default.publisher(for: NSNotification.Name("StudyDirectionChanged"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                let newDirection = UserDefaultsManager.shared.loadStudyDirection()
                print("📡 Direction changed to: \(newDirection.displayName)")
                self.studyDirection = newDirection
                self.loadStudyQueue()
            }
            .store(in: &cancellables)
    }
    
    private func observeWordsChanged() {
        NotificationCenter.default.publisher(for: NSNotification.Name("WordsChanged"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("📡 WordsChanged notification received - reloading queue")
                self.loadStudyQueue()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Study Queue
    func loadStudyQueue() {
        print("🔄 Loading study queue...")
        
        studyDirection = userDefaults.loadStudyDirection()
        
        do {
            allWords = try loadAllSelectedWords()
            print("✅ Loaded \(allWords.count) selected words")
            
            guard !allWords.isEmpty else {
                print("⚠️ No selected words found")
                studyQueue = []
                isSessionComplete = true
                return
            }
            
            loadOrCreateProgressForWords()
            currentSessionMaxPosition = calculateMaxSessionPosition()
            
            let sortedWords = prioritizeWordsForStudy(allWords)
            
            studyQueue = sortedWords.map { word in
                StudyCard(
                    id: UUID(),
                    wordId: word.id,
                    frontText: getFrontText(for: word),
                    backText: getBackText(for: word)
                )
            }
            
            print("✅ Study queue ready: \(studyQueue.count) cards")
            
            currentCardIndex = 0
            isSessionComplete = studyQueue.isEmpty
            cardsCompletedCount = 0
            
        } catch {
            print("❌ Load queue error: \(error)")
            studyQueue = []
            isSessionComplete = true
        }
    }
    
    private func loadOrCreateProgressForWords() {
        currentProgress.removeAll()
        
        for word in allWords {
            if let existingProgress = userDefaults.loadProgress(for: word.id, direction: studyDirection) {
                currentProgress[word.id] = existingProgress
            } else {
                let newProgress = Progress(wordId: word.id, direction: studyDirection)
                userDefaults.saveProgress(newProgress, for: word.id, direction: studyDirection)
                currentProgress[word.id] = newProgress
                print("✅ Created default progress for word ID: \(word.id)")
            }
        }
    }
    
    // MARK: - Study Actions
    
    func flipCard() {
        soundManager.playCardFlip()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
    }
    
    func replayAudio() {
        playCurrentWordAudio()
    }
    
    private func playCurrentWordAudio() {
        guard currentCardIndex < studyQueue.count else { return }
        let card = studyQueue[currentCardIndex]
        
        guard let word = allWords.first(where: { $0.id == card.wordId }) else { return }
        
        if studyDirection == .enToTr && !ttsPlayedForCurrentCard {
            ttsManager.speakEnglishWord(word.english)
            ttsPlayedForCurrentCard = true
        }
    }
    
    func answerCard(difficulty: CardDifficulty) {
        guard currentCardIndex < studyQueue.count else { return }
        
        soundManager.playClickSound()
        handleStudyResponse(difficulty: difficulty)
    }
    
    // MARK: - ✅ CRITICAL FIX: Proper Card Requeuing
    
    private func handleStudyResponse(difficulty: CardDifficulty) {
        let currentCard = studyQueue[currentCardIndex]
        guard var progress = currentProgress[currentCard.wordId] else { return }
        
        let newProgress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: difficulty.quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        // Save updated progress
        userDefaults.saveProgress(newProgress, for: currentCard.wordId, direction: studyDirection)
        currentProgress[currentCard.wordId] = newProgress
        
        // Update max session position if needed
        if let position = newProgress.sessionPosition, position > currentSessionMaxPosition {
            currentSessionMaxPosition = position
        }
        
        print("📝 Progress updated: word=\(currentCard.wordId), quality=\(difficulty.quality), learningPhase=\(newProgress.learningPhase), position=\(newProgress.sessionPosition ?? -1)")
        
        // ✅ CRITICAL: Requeue based on updated progress
        requeueAndContinue()
    }
    
    /// ✅ CRITICAL FIX: Re-sort queue after each card, remove graduated cards
    private func requeueAndContinue() {
        cardsCompletedCount += 1
        
        // Filter out graduated cards (not in learning phase anymore)
        let learningWords = allWords.filter { word in
            if let progress = currentProgress[word.id] {
                return progress.learningPhase
            }
            return false
        }
        
        // Check if all cards graduated
        if learningWords.isEmpty {
            print("✅ Session complete - all cards graduated!")
            isSessionComplete = true
            updateUserStats()
            return
        }
        
        // ✅ CRITICAL: Re-sort learning words by sessionPosition (priority)
        let sortedWords = prioritizeWordsForStudy(learningWords)
        
        // Rebuild queue
        studyQueue = sortedWords.map { word in
            StudyCard(
                id: UUID(),
                wordId: word.id,
                frontText: getFrontText(for: word),
                backText: getBackText(for: word)
            )
        }
        
        print("🔄 Queue reordered: \(studyQueue.count) learning cards remain")
        
        // ✅ Reset to first card (queue is now sorted by priority)
        currentCardIndex = 0
        isCardFlipped = false
        ttsPlayedForCurrentCard = false
        
        // Show ad every 12 cards
        if cardsCompletedCount % 12 == 0 && cardsCompletedCount > 0 {
            showNativeAd = true
            print("📢 Showing native ad (12 cards completed)")
        }
        
        updateUserStats()
    }
    
    func closeNativeAd() {
        withAnimation {
            showNativeAd = false
        }
        print("❌ Native ad closed")
    }
    
    private func updateUserStats() {
        var stats = userDefaults.loadUserStats()
        stats.totalWordsStudied += 1
        stats.wordsStudiedToday += 1
        stats.totalStudyTime += 1
        userDefaults.saveUserStats(stats)
    }
    
    // MARK: - Helper Methods
    
    private func prioritizeWordsForStudy(_ words: [Word]) -> [Word] {
        return words.sorted { word1, word2 in
            let progress1 = currentProgress[word1.id] ?? Progress(wordId: word1.id, direction: studyDirection)
            let progress2 = currentProgress[word2.id] ?? Progress(wordId: word2.id, direction: studyDirection)
            return progress1.studyPriority > progress2.studyPriority
        }
    }
    
    private func loadAllSelectedWords() throws -> [Word] {
        let selectedIds = userDefaults.loadSelectedWords()
        print("📋 Global selected IDs: \(selectedIds.count) words")
        
        var loadedWords: [Word] = []
        
        let packageFiles = ["en_tr_a1_001", "en_tr_a2_001", "en_tr_b1_001"]
        
        for packageId in packageFiles {
            do {
                let package = try jsonLoader.loadVocabularyPackage(filename: packageId)
                let selectedFromPackage = package.words.filter { selectedIds.contains($0.id) }
                loadedWords.append(contentsOf: selectedFromPackage)
            } catch {
                continue
            }
        }
        
        let userWords = userDefaults.loadUserAddedWords()
        let selectedUserWords = userWords.filter { selectedIds.contains($0.id) }
        loadedWords.append(contentsOf: selectedUserWords)
        
        print("📦 Loaded from packages: \(loadedWords.count - selectedUserWords.count)")
        print("✍️ Loaded user words: \(selectedUserWords.count)")
        
        return loadedWords
    }
    
    private func calculateMaxSessionPosition() -> Int {
        let learningProgress = currentProgress.values.filter { $0.learningPhase }
        return learningProgress.map { $0.sessionPosition ?? 0 }.max() ?? 0
    }
    
    // MARK: - Computed Properties
    
    var currentCard: StudyCard {
        guard currentCardIndex < studyQueue.count else {
            return StudyCard(id: UUID(), wordId: 0, frontText: "", backText: "")
        }
        return studyQueue[currentCardIndex]
    }
    
    var shouldShowSpeakerOnFront: Bool {
        return studyDirection == .enToTr
    }
    
    var hardTimeText: String {
        getCurrentTimeText(for: .hard)
    }
    
    var mediumTimeText: String {
        getCurrentTimeText(for: .medium)
    }
    
    var easyTimeText: String {
        getCurrentTimeText(for: .easy)
    }
    
    var currentCardColor: Color {
        let colorIndex = abs(currentCard.wordId) % studyCardColors.count
        return studyCardColors[colorIndex]
    }
    
    var currentExampleSentence: String {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return "" }
        
        switch studyDirection {
        case .enToTr:
            return isCardFlipped ? word.example.tr : word.example.en
        case .trToEn:
            return isCardFlipped ? word.example.en : word.example.tr
        }
    }
    
    private func getCurrentTimeText(for difficulty: CardDifficulty) -> String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Soon" }
        return progress.getButtonTimeText(quality: difficulty.quality)
    }
    
    private func getFrontText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr:
            return word.english
        case .trToEn:
            return word.turkish
        }
    }
    
    private func getBackText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr:
            return word.turkish
        case .trToEn:
            return word.english
        }
    }
}
