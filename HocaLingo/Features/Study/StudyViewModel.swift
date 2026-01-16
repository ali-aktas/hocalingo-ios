//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ MEGA FIX:
//  1. Random 30 pastel colors (not progress-based)
//  2. Real-time update system (NotificationCenter)
//  3. TTS timing fix (TR->EN only on flip)
//  4. No TTS on init (fixes home screen sound bug)
//  5. First card direction fix (proper front/back logic)
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

// MARK: - StudyViewModel
class StudyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCardIndex: Int = 0 {
        didSet {
            // ✅ FIX: Only trigger TTS for EN->TR direction
            // TR->EN: TTS will be triggered on flip, not on card change
            if currentCardIndex != oldValue && currentCardIndex < studyQueue.count {
                if studyDirection == .enToTr {
                    // EN->TR: Auto-play immediately (English on front)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.playCurrentWordAudio()
                    }
                }
                // TR->EN: Do NOT auto-play here, will play on flip
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
    
    // ✅ FIX 4: Track if this is first load (to prevent init TTS)
    private var isFirstLoad: Bool = true
    
    // ✅ FIX 5: Track if TTS already played for current card (TR->EN only once)
    private var ttsPlayedForCurrentCard: Bool = false
    
    // Audio Managers
    private let ttsManager = TTSManager.shared
    private let soundManager = SoundManager.shared
    
    // MARK: - Computed Properties
    var currentCard: StudyCard {
        guard !studyQueue.isEmpty, currentCardIndex < studyQueue.count else {
            return StudyCard(
                id: UUID(),
                wordId: 0,
                frontText: "No cards",
                backText: "No cards"
            )
        }
        return studyQueue[currentCardIndex]
    }
    
    var totalCards: Int {
        return studyQueue.count
    }
    
    var remainingCards: Int {
        return max(0, totalCards - currentCardIndex)
    }
    
    var progressText: String {
        return "\(currentCardIndex + 1) / \(totalCards)"
    }
    
    var hardTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Birazdan" }
        return progress.learningPhase ? "Birazdan" : "Sonra"
    }
    
    var mediumTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Sonra" }
        return progress.learningPhase ? "Sonra" : "Bugün"
    }
    
    var easyTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Bugün" }
        if progress.learningPhase {
            return "Bugün"
        } else {
            let days = Int(progress.intervalDays)
            return days <= 1 ? "Bugün" : "\(days)g"
        }
    }
    
    /// ✅ FIX 1: Random pastel color based on wordId (not progress)
    var currentCardColor: Color {
        return Color.pastelColor(for: currentCard.wordId)
    }
    
    /// ✅ FIX 3: Direction-aware speaker button placement
    /// EN→TR: Speaker on FRONT (English front)
    /// TR→EN: Speaker on BACK (English back)
    var shouldShowSpeakerOnFront: Bool {
        return studyDirection == .enToTr
    }
    
    /// ✅ FIX 5: Example sentence based on direction and flip state
    var currentExampleSentence: String {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return "" }
        
        // Show appropriate example based on which side is visible
        switch studyDirection {
        case .enToTr:
            // English front, Turkish back
            return isCardFlipped ? word.example.tr : word.example.en
        case .trToEn:
            // Turkish front, English back
            return isCardFlipped ? word.example.en : word.example.tr
        case .mixed:
            // Random: show example matching front text
            if currentCard.frontText == word.english {
                return isCardFlipped ? word.example.tr : word.example.en
            } else {
                return isCardFlipped ? word.example.en : word.example.tr
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupNotificationObservers()
        loadWords()
        // ✅ FIX 4: Mark first load complete after init
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isFirstLoad = false
        }
    }
    
    // MARK: - Notification Observers
    
    /// ✅ FIX 2: Setup real-time update observers
    private func setupNotificationObservers() {
        // Observe direction changes from ProfileView
        NotificationCenter.default.publisher(for: NSNotification.Name("StudyDirectionChanged"))
            .sink { [weak self] _ in
                print("📡 StudyViewModel: Direction changed notification received")
                self?.reloadStudySession()
            }
            .store(in: &cancellables)
        
        // Observe word selection changes from WordSelectionView
        NotificationCenter.default.publisher(for: NSNotification.Name("WordSelectionChanged"))
            .sink { [weak self] _ in
                print("📡 StudyViewModel: Word selection changed notification received")
                self?.reloadStudySession()
            }
            .store(in: &cancellables)
    }
    
    /// ✅ FIX 2: Reload study session (for real-time updates)
    func reloadStudySession() {
        print("🔄 Reloading study session...")
        
        // Reset state
        currentCardIndex = 0
        isCardFlipped = false
        isSessionComplete = false
        currentSessionMaxPosition = 0
        ttsPlayedForCurrentCard = false
        
        // Reload data
        loadWords()
        
        print("✅ Study session reloaded!")
    }
    
    // MARK: - Data Loading
    
    private func loadWords() {
        let selectedWordIds = UserDefaultsManager.shared.loadSelectedWords()
        let selectedPackageId = UserDefaultsManager.shared.loadSelectedPackage() ?? ""
        
        guard !selectedWordIds.isEmpty, !selectedPackageId.isEmpty else {
            print("⚠️ No selected words or package")
            return
        }
        
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: selectedPackageId)
            allWords = vocabPackage.words.filter { selectedWordIds.contains($0.id) }
            print("✅ Loaded \(allWords.count) words from package: \(selectedPackageId)")
        } catch {
            print("❌ Failed to load package: \(error.localizedDescription)")
        }
        
        studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        print("🔄 Study direction loaded: \(studyDirection.displayName)")
        
        loadProgress()
        initializeStudyQueue()
    }
    
    private func loadProgress() {
        currentProgress = UserDefaultsManager.shared.loadAllProgress(for: studyDirection)
        print("✅ Loaded \(currentProgress.count) progress records for direction: \(studyDirection.displayName)")
    }
    
    private func initializeStudyQueue() {
        let newWords = allWords.filter { word in
            currentProgress[word.id] == nil
        }
        
        let learningWords = allWords.filter { word in
            guard let progress = currentProgress[word.id] else { return false }
            return progress.learningPhase && progress.direction == studyDirection
        }
        
        let wordsToStudy = newWords + learningWords
        
        print("📚 Words to study for \(studyDirection.displayName):")
        print("   - New words: \(newWords.count)")
        print("   - Learning words: \(learningWords.count)")
        print("   - Total: \(wordsToStudy.count)")
        
        studyQueue = wordsToStudy.map { word in
            let (front, back) = getCardTexts(for: word)
            return StudyCard(
                id: UUID(),
                wordId: word.id,
                frontText: front,
                backText: back
            )
        }
        
        currentCardIndex = 0
        currentSessionMaxPosition = 0
        ttsPlayedForCurrentCard = false
        
        print("✅ Study queue initialized with \(studyQueue.count) cards")
        
        // ✅ FIX 4: Do NOT auto-play TTS on init (prevents home screen bug)
        // TTS will only play:
        // - EN->TR: When currentCardIndex changes (didSet)
        // - TR->EN: When card is flipped (flipCard())
        print("🔇 Skipping initial TTS (will play on card change or flip)")
    }
    
    private func getCardTexts(for word: Word) -> (front: String, back: String) {
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
        
        // ✅ FIX 3: TR->EN TTS timing - ONLY on flip, and ONLY ONCE
        if isCardFlipped && studyDirection == .trToEn && !ttsPlayedForCurrentCard {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.playCurrentWordAudio()
                self?.ttsPlayedForCurrentCard = true
                print("🔊 TR->EN: TTS played on flip (one time only)")
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
        
        var progress = currentProgress[card.wordId] ?? Progress(
            wordId: card.wordId,
            direction: studyDirection
        )
        
        progress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        currentProgress[card.wordId] = progress
        UserDefaultsManager.shared.saveProgress(progress, for: card.wordId)
        
        print("📝 Progress updated:")
        print("   - Word ID: \(card.wordId)")
        print("   - Direction: \(progress.direction.displayName)")
        print("   - Quality: \(quality)")
        print("   - Learning Phase: \(progress.learningPhase)")
        print("   - Interval: \(Int(progress.intervalDays)) days")
        
        // Reset TTS flag for next card
        ttsPlayedForCurrentCard = false
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
            currentCardIndex += 1
            currentSessionMaxPosition = max(currentSessionMaxPosition, currentCardIndex)
        }
        
        if currentCardIndex < studyQueue.count {
            let answeredCard = studyQueue.remove(at: currentCardIndex - 1)
            
            if progress.learningPhase {
                reinsertCardInQueue(card: answeredCard, quality: quality)
            } else {
                print("🎓 Card graduated - removed from queue: wordId=\(answeredCard.wordId)")
            }
        }
        
        if currentCardIndex >= studyQueue.count {
            handleQueueCompletion()
        }
    }
    
    private func reinsertCardInQueue(card: StudyCard, quality: Int) {
        let remainingSize = studyQueue.count
        
        let offsetPercentage: Float = {
            switch quality {
            case SpacedRepetition.QUALITY_HARD: return 0.60
            case SpacedRepetition.QUALITY_MEDIUM: return 0.80
            case SpacedRepetition.QUALITY_EASY: return 1.0
            default: return 1.0
            }
        }()
        
        let offset = Int(Float(remainingSize) * offsetPercentage)
        let newIndex = min(offset, remainingSize)
        
        studyQueue.insert(card, at: newIndex)
        
        print("🔄 Reinserted card: wordId=\(card.wordId), quality=\(quality), position=\(currentCardIndex)→\(newIndex), queue=\(studyQueue.count)")
    }
    
    private func handleQueueCompletion() {
        print("🏁 Queue completed at index \(currentCardIndex)")
        
        let learningWordIds = currentProgress.filter { (wordId, progress) in
            progress.learningPhase && progress.direction == studyDirection
        }.map { $0.key }
        
        let learningWords = allWords.filter { learningWordIds.contains($0.id) }
        
        if !learningWords.isEmpty {
            print("🔄 \(learningWords.count) learning cards remain - reloading queue")
            
            studyQueue = learningWords.map { word in
                let (front, back) = getCardTexts(for: word)
                return StudyCard(
                    id: UUID(),
                    wordId: word.id,
                    frontText: front,
                    backText: back
                )
            }
            
            currentCardIndex = 0
            ttsPlayedForCurrentCard = false
        } else {
            print("🎉 All cards graduated! Session complete for direction: \(studyDirection.displayName)")
            completeSession()
        }
    }
    
    private func completeSession() {
        print("✅ Study session complete!")
        isSessionComplete = true
    }
    
    func restartSession() {
        isSessionComplete = false
        currentCardIndex = 0
        ttsPlayedForCurrentCard = false
        loadWords()
    }
}
