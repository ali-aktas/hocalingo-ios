//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: 20 vibrant card colors - Android parity
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
    @Published var showNativeAd: Bool = false  // ✅ NEW: Ad support
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private let jsonLoader = JSONLoader()
    private var currentSessionMaxPosition: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var isFirstLoad: Bool = true
    private var ttsPlayedForCurrentCard: Bool = false
    private var cardsCompletedCount: Int = 0  // ✅ NEW: For ad triggers
    
    // Managers
    private let soundManager = SoundManager.shared
    private let ttsManager = TTSManager.shared
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Initialization
    init() {
        loadStudyQueue()
        setupDirectionObserver()
    }
    
    // MARK: - Setup
    
    private func setupDirectionObserver() {
        NotificationCenter.default.publisher(for: .studyDirectionChanged)
            .sink { [weak self] notification in
                if let newDirection = notification.object as? StudyDirection {
                    print("📡 Direction changed to: \(newDirection.displayName)")
                    self?.studyDirection = newDirection
                    self?.loadStudyQueue()
                }
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
            cardsCompletedCount = 0  // ✅ Reset ad counter
            
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
    
    private func getFrontText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr: return word.english
        case .trToEn: return word.turkish
        case .mixed: return Bool.random() ? word.english : word.turkish
        }
    }
    
    private func getBackText(for word: Word) -> String {
        switch studyDirection {
        case .enToTr: return word.turkish
        case .trToEn: return word.english
        case .mixed: return studyQueue[currentCardIndex].frontText == word.english ? word.turkish : word.english
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
    
    /// ✅ UPDATED: Uses Android's 20 vibrant colors
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
        case .mixed:
            if currentCard.frontText == word.english {
                return isCardFlipped ? word.example.tr : word.example.en
            } else {
                return isCardFlipped ? word.example.en : word.example.tr
            }
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
        
        // ✅ CRITICAL FIX: ALWAYS speak English word (regardless of direction)
        // TTS button is always on the English side
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
        
        let oldProgress = currentProgress[card.wordId] ?? Progress(
            wordId: card.wordId,
            direction: studyDirection
        )
        
        let wasInLearning = oldProgress.learningPhase
        
        var progress = SpacedRepetition.calculateNextReview(
            currentProgress: oldProgress,
            quality: quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        let isNowInReview = !progress.learningPhase
        let hasGraduated = wasInLearning && isNowInReview
        
        currentProgress[card.wordId] = progress
        
        userDefaults.saveProgress(
            progress,
            for: card.wordId,
            direction: studyDirection
        )
        
        print("📝 Progress updated:")
        print("   - Word ID: \(card.wordId)")
        print("   - Direction: \(progress.direction.displayName)")
        print("   - Quality: \(quality)")
        print("   - HAS GRADUATED: \(hasGraduated)")
        
        if hasGraduated {
            userDefaults.incrementDailyGraduations()
            userDefaults.updateMasteredWordsCount()
            print("🎓 WORD GRADUATED! Daily progress +1")
        }
        
        userDefaults.incrementCardsStudied()
        
        ttsPlayedForCurrentCard = false
        
        // ✅ YÖNTEM 3: Two-Phase Animation
        guard isCardFlipped else {
            // Kart zaten false ise direkt geç
            moveToNextCard()
            return
        }
        
        // 1. Flip back animasyonu başlat (0.25 saniye)
        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
            isCardFlipped = false
        }
        
        // 2. Flip yarı noktasında (90°) content değiştir
        // Timing: 0.12 saniye = flip animasyonunun yarısı
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.moveToNextCard()  // Renk ve kelimeler değişir
        }
    }
    
    private func moveToNextCard() {
        currentCardIndex += 1
        cardsCompletedCount += 1
        
        // ✅ ANDROID PARITY: Show ad every 12 cards
        if cardsCompletedCount % 12 == 0 && cardsCompletedCount > 0 {
            showNativeAd = true
            print("📢 Showing native ad (12 cards completed)")
        }
        
        if currentCardIndex >= studyQueue.count {
            isSessionComplete = true
            print("✅ Study session complete!")
        }
    }
    
    /// ✅ NEW: Close native ad
    func closeNativeAd() {
        withAnimation {
            showNativeAd = false
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let studyDirectionChanged = Notification.Name("studyDirectionChanged")
}
