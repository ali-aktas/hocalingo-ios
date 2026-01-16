//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Direction-based filtering (EN→TR / TR→EN / Mixed)
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
    private var currentProgress: [Int: Progress] = [:] // ✅ UNCHANGED - still [Int: Progress]
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
    
    var currentCardColor: Color {
        // Dynamic card color based on index
        let colors: [Color] = [
            Color(hex: "FF6B6B"),  // Red
            Color(hex: "4ECDC4"),  // Turquoise
            Color(hex: "45B7D1"),  // Blue
            Color(hex: "FFA07A"),  // Salmon
            Color(hex: "98D8C8")   // Mint
        ]
        return colors[currentCardIndex % colors.count]
    }
    
    var currentExampleSentence: String {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return "" }
        
        // Show front example on front, back example on back
        if !isCardFlipped {
            return studyDirection == .enToTr ? word.example.en : word.example.tr
        } else {
            return studyDirection == .enToTr ? word.example.tr : word.example.en
        }
    }
    
    // MARK: - Initialization
    
    init() {
        loadWords()
    }
    
    // MARK: - Data Loading
    
    /// ✅ UPDATED: Load words and initialize queue with direction filter
    private func loadWords() {
        // Load selected words and package ID
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
        
        // ✅ STEP 1: Load study direction from UserDefaults
        studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        print("🔄 Study direction loaded: \(studyDirection.displayName)")
        
        // ✅ STEP 2: Load progress (filtered by direction)
        loadProgress()
        
        // ✅ STEP 3: Initialize study queue (with direction filter)
        initializeStudyQueue()
    }
    
    /// ✅ UPDATED: Load progress filtered by active direction
    private func loadProgress() {
        // ✅ CRITICAL: Use new direction-aware API
        // This loads ONLY progress records for the active direction
        currentProgress = UserDefaultsManager.shared.loadAllProgress(for: studyDirection)
        
        print("✅ Loaded \(currentProgress.count) progress records for direction: \(studyDirection.displayName)")
    }
    
    /// ✅ UPDATED: Initialize study queue with direction-filtered progress
    private func initializeStudyQueue() {
        // ✅ Filter 1: New words (no progress for active direction)
        let newWords = allWords.filter { word in
            currentProgress[word.id] == nil
        }
        
        // ✅ Filter 2: Learning phase words (progress exists AND learningPhase = true)
        let learningWords = allWords.filter { word in
            guard let progress = currentProgress[word.id] else { return false }
            return progress.learningPhase && progress.direction == studyDirection
        }
        
        let wordsToStudy = newWords + learningWords
        
        print("📚 Words to study for \(studyDirection.displayName):")
        print("   - New words: \(newWords.count)")
        print("   - Learning words: \(learningWords.count)")
        print("   - Total: \(wordsToStudy.count)")
        
        // Create study queue with correct front/back text
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
    
    /// ✅ UNCHANGED: Get card texts based on direction
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
    
    /// ✅ UNCHANGED: Unlimited flip with toggle + sound
    func flipCard() {
        // Play flip sound on EVERY flip (front→back AND back→front)
        soundManager.playCardFlip()
        
        // Toggle flip state (unlimited flips)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
        
        print("🔄 Card flipped - isFlipped: \(isCardFlipped)")
    }
    
    /// ✅ UNCHANGED: Manual audio replay
    func replayAudio() {
        playCurrentWordAudio()
        print("🔊 Manual audio replay")
    }
    
    /// ✅ UNCHANGED: Play TTS for English word only
    func playCurrentWordAudio() {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return }
        
        // ALWAYS speak English word with English voice
        ttsManager.speak(text: word.english, languageCode: "en-US")
        print("🔊 TTS playing: \(word.english)")
    }
    
    /// ✅ UPDATED: Answer card with direction-aware progress saving
    func answerCard(difficulty: CardDifficulty) {
        guard isCardFlipped else { return }
        
        // Play click sound
        soundManager.playClickSound()
        
        let card = currentCard
        let quality = difficulty.quality
        
        // ✅ CRITICAL: Get or create progress FOR ACTIVE DIRECTION
        var progress = currentProgress[card.wordId] ?? Progress(
            wordId: card.wordId,
            direction: studyDirection  // ✅ Use active direction
        )
        
        // Update progress using SpacedRepetition algorithm
        progress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        // ✅ Save updated progress (with direction)
        currentProgress[card.wordId] = progress
        UserDefaultsManager.shared.saveProgress(progress, for: card.wordId)
        
        print("📝 Progress updated:")
        print("   - Word ID: \(card.wordId)")
        print("   - Direction: \(progress.direction.displayName)")
        print("   - Quality: \(quality)")
        print("   - Learning Phase: \(progress.learningPhase)")
        print("   - Interval: \(Int(progress.intervalDays)) days")
        
        // Move to next card with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
            currentCardIndex += 1
            currentSessionMaxPosition = max(currentSessionMaxPosition, currentCardIndex)
        }
        
        // ✅ UNCHANGED: Reinsert card if still learning
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
    
    /// ✅ UNCHANGED: Reinsert card into queue based on quality
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
    
    /// ✅ UPDATED: Handle queue completion with direction filter
    private func handleQueueCompletion() {
        print("🏁 Queue completed at index \(currentCardIndex)")
        
        // ✅ Filter learning phase cards for ACTIVE DIRECTION
        let learningWordIds = currentProgress.filter { (wordId, progress) in
            progress.learningPhase && progress.direction == studyDirection
        }.map { $0.key }
        
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
            print("🎉 All cards graduated! Session complete for direction: \(studyDirection.displayName)")
            completeSession()
        }
    }
    
    /// ✅ UNCHANGED: Complete study session
    private func completeSession() {
        print("✅ Study session complete!")
        shouldDismiss = true
    }
}
