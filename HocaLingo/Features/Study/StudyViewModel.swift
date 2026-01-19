//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Removed mixed study direction (only EN→TR and TR→EN)
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
/// ✅ ANDROID PARITY: Exactly 20 vibrant colors matching StudyViewModel.kt
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
    @Published var showNativeAd: Bool = false  // ✅ For ad support
    
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
        observeDirectionChanges()
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
            
            loadProgressForWords()
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
    
    private func loadProgressForWords() {
        currentProgress.removeAll()
        
        for word in allWords {
            if let progress = userDefaults.loadProgress(for: word.id, direction: studyDirection) {
                currentProgress[word.id] = progress
            }
        }
        
        print("📊 Loaded progress for \(currentProgress.count) words")
    }
    
    // ✅ UPDATED: Removed .mixed case
    private func getFrontText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr: return word.english
        case .trToEn: return word.turkish
        }
    }
    
    // ✅ UPDATED: Removed .mixed case
    private func getBackText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr: return word.turkish
        case .trToEn: return word.english
        }
    }
    
    private func prioritizeWordsForStudy(_ words: [Word]) -> [Word] {
        return words.sorted { word1, word2 in
            let progress1 = currentProgress[word1.id] ?? Progress(wordId: word1.id, direction: studyDirection)
            let progress2 = currentProgress[word2.id] ?? Progress(wordId: word2.id, direction: studyDirection)
            return progress1.studyPriority > progress2.studyPriority
        }
    }
    
    private func loadAllSelectedWords() throws -> [Word] {
        let selectedIds = userDefaults.loadSelectedWords()
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
    
    // ✅ UPDATED: Removed .mixed case
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
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else {
            return "Soon"
        }
        
        let progress = currentProgress[word.id] ?? Progress(wordId: word.id, direction: studyDirection)
        let testProgress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: difficulty.quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        return SpacedRepetition.getTimeUntilReview(nextReviewAt: testProgress.nextReviewAt)
    }
    
    // MARK: - Actions
    
    func flipCard() {
        soundManager.playCardFlip()
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            isCardFlipped.toggle()
        }
        
        if isCardFlipped && studyDirection == .trToEn {
            if let word = allWords.first(where: { $0.id == currentCard.wordId }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    self?.ttsManager.speak(text: word.english, languageCode: "en")
                }
            }
        }
    }
    
    func replayAudio() {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return }
        
        // ✅ CRITICAL: ALWAYS speak English word (regardless of direction)
        ttsManager.speak(text: word.english, languageCode: "en")
    }
    
    func playCurrentWordAudio() {
        guard !ttsPlayedForCurrentCard else { return }
        guard studyDirection == .enToTr else { return }
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return }
        
        ttsManager.speak(text: word.english, languageCode: "en")
        ttsPlayedForCurrentCard = true
    }
    
    func answerCard(difficulty: CardDifficulty) {
        let card = currentCard
        let quality = difficulty.quality
        
        let oldProgress = currentProgress[card.wordId] ?? Progress(wordId: card.wordId, direction: studyDirection)
        
        let newProgress = SpacedRepetition.calculateNextReview(
            currentProgress: oldProgress,
            quality: quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        currentProgress[card.wordId] = newProgress
        userDefaults.saveProgress(newProgress, for: card.wordId, direction: studyDirection)  // ✅ FIXED: Add missing parameters
        
        if newProgress.learningPhase && newProgress.sessionPosition ?? 0 > currentSessionMaxPosition {
            currentSessionMaxPosition = newProgress.sessionPosition ?? 0
        }
        
        // Move to next card with animation
        moveToNextCard()
    }
    
    private func moveToNextCard() {
        soundManager.playSwipeRight()  // ✅ FIXED: Use correct method name
        
        cardsCompletedCount += 1
        
        if currentCardIndex < studyQueue.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentCardIndex += 1
                isCardFlipped = false
                ttsPlayedForCurrentCard = false
            }
            
            // ✅ Show ad every 12 cards (Android parity)
            if cardsCompletedCount % 12 == 0 && cardsCompletedCount > 0 {
                showNativeAd = true
                print("📢 Showing native ad (12 cards completed)")
            }
        } else {
            isSessionComplete = true
        }
        
        updateUserStats()
    }
    
    /// ✅ Close native ad and continue studying
    func closeNativeAd() {
        withAnimation {
            showNativeAd = false
        }
        print("❌ Native ad closed")
    }
    
    private func updateUserStats() {
        var stats = userDefaults.loadUserStats()
        stats.wordsLearned += 1  // ✅ FIXED: Use correct property name
        stats.totalStudyTime += 1
        userDefaults.saveUserStats(stats)
    }
}
