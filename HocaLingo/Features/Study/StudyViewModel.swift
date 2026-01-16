//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ FIXED: Unlimited flip + TTS + Sound effects (Report compliant)
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
    @Published var currentCardIndex: Int = 0
    @Published var isCardFlipped: Bool = false
    @Published var studyQueue: [StudyCard] = []
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var shouldDismiss: Bool = false
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private let jsonLoader = JSONLoader()
    private var currentSessionMaxPosition: Int = 0
    
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
    
    // Button time texts (Android-style)
    var hardTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Birazdan" }
        if progress.learningPhase {
            return "Birazdan" // Learning: will repeat soon
        } else {
            return "Sonra" // Review: later today/tomorrow
        }
    }
    
    var mediumTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Sonra" }
        if progress.learningPhase {
            return "Sonra" // Learning: will repeat in a bit
        } else {
            return "Bugün" // Review: today or tomorrow
        }
    }
    
    var easyTimeText: String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Bugün" }
        if progress.learningPhase {
            return "Bugün" // Learning: might graduate today
        } else {
            let days = Int(progress.intervalDays)
            return days <= 1 ? "Bugün" : "\(days)g" // Review: actual interval
        }
    }
    
    // Card color based on progress (Android-style)
    var currentCardColor: Color {
        guard let progress = currentProgress[currentCard.wordId] else {
            return Color(hex: "FFE5E5") // Light red for new words
        }
        
        if progress.isMastered {
            return Color(hex: "E8F5E9") // Light green - Mastered
        } else if progress.repetitions >= 5 {
            return Color(hex: "FFF9C4") // Light yellow - Advanced
        } else if progress.learningPhase {
            return Color(hex: "FFF3E0") // Light orange - Learning
        } else {
            return Color(hex: "E1F5FE") // Light blue - Review
        }
    }
    
    // Example sentence for current card
    var currentExampleSentence: String {
        // Get the word object
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else {
            return ""
        }
        
        // Return example based on study direction
        switch studyDirection {
        case .enToTr:
            return word.example.en
        case .trToEn:
            return word.example.tr
        case .mixed:
            // Show example in the language of front text
            if currentCard.frontText == word.english {
                return word.example.en
            } else {
                return word.example.tr
            }
        }
    }
    
    // MARK: - Initialization
    init() {
        loadStudyData()
    }
    
    // MARK: - Data Loading
    private func loadStudyData() {
        let selectedWordIds = UserDefaultsManager.shared.loadSelectedWords()
        let selectedPackageId = UserDefaultsManager.shared.loadSelectedPackage() ?? ""
        
        guard !selectedWordIds.isEmpty, !selectedPackageId.isEmpty else {
            print("⚠️ No selected words or package")
            return
        }
        
        // Load package from JSON
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: selectedPackageId)
            allWords = vocabPackage.words.filter { selectedWordIds.contains($0.id) }
            print("✅ Loaded \(allWords.count) words from package: \(selectedPackageId)")
        } catch {
            print("❌ Failed to load package: \(error.localizedDescription)")
        }
        
        // Load existing progress
        loadProgress()
        
        // Load study direction
        studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        
        // Initialize study queue
        initializeStudyQueue()
    }
    
    private func loadProgress() {
        let progressDict = UserDefaultsManager.shared.loadAllProgress()
        currentProgress = progressDict
        print("✅ Loaded progress for \(currentProgress.count) words")
    }
    
    private func initializeStudyQueue() {
        // Filter words: New + Learning phase only
        let newWords = allWords.filter { currentProgress[$0.id] == nil }
        let learningWords = allWords.filter {
            guard let progress = currentProgress[$0.id] else { return false }
            return progress.learningPhase
        }
        
        let wordsToStudy = newWords + learningWords
        
        print("📚 Words to study: \(wordsToStudy.count) (new: \(newWords.count), learning: \(learningWords.count))")
        
        // Create study queue
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
        
        print("✅ Study queue initialized with \(studyQueue.count) cards")
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
    
    /// ✅ FIXED: Unlimited flip with toggle + sound on EVERY flip
    func flipCard() {
        // Play flip sound on EVERY flip (front→back AND back→front)
        soundManager.playCardFlip()
        
        // Toggle flip state (unlimited flips)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
        
        print("🔄 Card flipped - isFlipped: \(isCardFlipped)")
    }
    
    /// Manual audio replay (speaker button)
    func replayAudio() {
        playCurrentWordAudio()
        print("🔊 Manual audio replay")
    }
    
    /// Play TTS for English word only (front side)
    /// ✅ Called by View on first card appearance (auto-play once)
    func playCurrentWordAudio() {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return }
        
        // ALWAYS speak English word with English voice
        ttsManager.speak(text: word.english, languageCode: "en-US")
        print("🔊 TTS playing: \(word.english)")
    }
    
    /// Answer card with difficulty (HARD/MEDIUM/EASY)
    func answerCard(difficulty: CardDifficulty) {
        guard isCardFlipped else { return }
        
        // Play click sound
        soundManager.playClickSound()
        
        let card = currentCard
        let quality = difficulty.quality
        
        // Get or create progress
        var progress = currentProgress[card.wordId] ?? Progress(wordId: card.wordId, direction: studyDirection)
        
        // Update progress using SpacedRepetition algorithm (static method)
        progress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        // Save updated progress
        currentProgress[card.wordId] = progress
        UserDefaultsManager.shared.saveProgress(progress, for: card.wordId)
        
        print("📝 Progress updated: wordId=\(card.wordId), quality=\(quality), learning=\(progress.learningPhase), interval=\(Int(progress.intervalDays))d")
        
        // Move to next card with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
            currentCardIndex += 1
            currentSessionMaxPosition = max(currentSessionMaxPosition, currentCardIndex)
        }
        
        // ANDROID LOGIC: Reinsert card if still learning
        if currentCardIndex < studyQueue.count {
            let answeredCard = studyQueue.remove(at: currentCardIndex - 1)
            
            if progress.learningPhase {
                reinsertCardInQueue(card: answeredCard, quality: quality)
            } else {
                print("🎓 Card graduated - removed from queue: wordId=\(answeredCard.wordId)")
            }
        }
        
        // Check if queue is empty
        if currentCardIndex >= studyQueue.count {
            handleQueueCompletion()
        }
    }
    
    /// ANDROID LOGIC: Reinsert card into queue based on quality
    private func reinsertCardInQueue(card: StudyCard, quality: Int) {
        let remainingSize = studyQueue.count
        
        // Calculate offset percentage (Android formula)
        let offsetPercentage: Float = {
            switch quality {
            case SpacedRepetition.QUALITY_HARD: return 0.60   // 60% - near front
            case SpacedRepetition.QUALITY_MEDIUM: return 0.80 // 80% - middle-back
            case SpacedRepetition.QUALITY_EASY: return 1.0    // 100% - end
            default: return 1.0
            }
        }()
        
        let offset = Int(Float(remainingSize) * offsetPercentage)
        let newIndex = min(offset, remainingSize)
        
        studyQueue.insert(card, at: newIndex)
        
        print("🔄 Reinserted card: wordId=\(card.wordId), quality=\(quality), position=\(currentCardIndex)→\(newIndex), queue=\(studyQueue.count)")
    }
    
    /// Handle queue completion
    private func handleQueueCompletion() {
        print("🏁 Queue completed at index \(currentCardIndex)")
        
        // Filter learning phase cards
        let learningWordIds = currentProgress.filter { $0.value.learningPhase }.map { $0.key }
        let learningWords = allWords.filter { learningWordIds.contains($0.id) }
        
        if !learningWords.isEmpty {
            print("🔄 \(learningWords.count) learning cards remain - reloading queue")
            
            // Recreate queue with learning cards
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
        } else {
            print("🎉 All cards graduated! Session complete")
            completeSession()
        }
    }
    
    /// Complete study session
    private func completeSession() {
        print("✅ Study session complete!")
        shouldDismiss = true
    }
}
