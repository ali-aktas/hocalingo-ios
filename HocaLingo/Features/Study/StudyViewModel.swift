//
//  StudyViewModel.swift (FINAL FIX)
//  HocaLingo
//
//  ✅ FIXED: Removed duplicate shouldShowSpeakerOnFront, added .mixed case
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
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private let jsonLoader = JSONLoader()
    private var currentSessionMaxPosition: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var isFirstLoad: Bool = true
    private var ttsPlayedForCurrentCard: Bool = false
    
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
                    self?.handleDirectionChange(to: newDirection)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleDirectionChange(to newDirection: StudyDirection) {
        guard newDirection != studyDirection else { return }
        
        print("🔄 Direction changed: \(studyDirection.displayName) → \(newDirection.displayName)")
        studyDirection = newDirection
        loadStudyQueue()
    }
    
    // MARK: - Load Queue
    
    private func loadStudyQueue() {
        do {
            let selectedWordIds = userDefaults.loadSelectedWords()
            guard !selectedWordIds.isEmpty else {
                isSessionComplete = true
                return
            }
            
            allWords = try loadAllSelectedWords()
            currentProgress = userDefaults.loadAllProgress(for: studyDirection)
            let sortedWords = sortWordsByPriority(allWords, direction: studyDirection)
            
            studyQueue = sortedWords.map { word in
                let (front, back) = getCardTexts(for: word)
                return StudyCard(
                    id: UUID(),
                    wordId: word.id,
                    frontText: front,
                    backText: back
                )
            }
            
            currentSessionMaxPosition = calculateMaxSessionPosition()
            
            print("📚 Study queue loaded:")
            print("   - Total words: \(studyQueue.count)")
            print("   - Direction: \(studyDirection.displayName)")
            print("   - Max session position: \(currentSessionMaxPosition)")
            
            isFirstLoad = false
            
        } catch {
            print("❌ Failed to load study queue: \(error)")
            isSessionComplete = true
        }
    }
    
    private func sortWordsByPriority(_ words: [Word], direction: StudyDirection) -> [Word] {
        return words.sorted { word1, word2 in
            let progress1 = currentProgress[word1.id] ?? Progress(wordId: word1.id, direction: direction)
            let progress2 = currentProgress[word2.id] ?? Progress(wordId: word2.id, direction: direction)
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
        return Color.pastelColor(for: currentCard.wordId)
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
        return progress.getButtonTimeText(quality: difficulty.quality)
    }
    
    private func getCardTexts(for word: Word) -> (String, String) {
        switch studyDirection {
        case .enToTr:
            return (word.english, word.turkish)
        case .trToEn:
            return (word.turkish, word.english)
        case .mixed:
            return Bool.random() ? (word.english, word.turkish) : (word.turkish, word.english)
        }
    }
    
    // MARK: - Card Actions
    
    func flipCard() {
        soundManager.playCardFlip()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
        
        print("🔄 Card flipped - isFlipped: \(isCardFlipped)")
        
        if isCardFlipped && studyDirection == .trToEn && !ttsPlayedForCurrentCard {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.playCurrentWordAudio()
                self?.ttsPlayedForCurrentCard = true
                print("🔊 TR->EN: TTS played on flip")
            }
        }
    }
    
    func replayAudio() {
        playCurrentWordAudio()
        print("🔊 Manual audio replay")
    }
    
    func playCurrentWordAudio() {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return }
        ttsManager.speak(text: word.english, languageCode: "en-US")
        print("🔊 TTS playing: \(word.english)")
    }
    
    func answerCard(difficulty: CardDifficulty) {
        guard isCardFlipped else { return }
        
        soundManager.playClickSound()
        
        let card = currentCard
        let quality = difficulty.quality
        
        var oldProgress = currentProgress[card.wordId] ?? Progress(
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
        print("   - Was in learning: \(wasInLearning)")
        print("   - Is now in review: \(isNowInReview)")
        print("   - HAS GRADUATED: \(hasGraduated)")
        print("   - Interval: \(Int(progress.intervalDays)) days")
        
        if hasGraduated {
            userDefaults.incrementDailyGraduations()
            userDefaults.updateMasteredWordsCount()
            print("🎓 WORD GRADUATED! Daily progress +1")
        }
        
        userDefaults.incrementCardsStudied()
        
        ttsPlayedForCurrentCard = false
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
        }
        
        moveToNextCard()
    }
    
    private func moveToNextCard() {
        currentCardIndex += 1
        
        if currentCardIndex >= studyQueue.count {
            isSessionComplete = true
            print("✅ Study session complete!")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let studyDirectionChanged = Notification.Name("studyDirectionChanged")
}
