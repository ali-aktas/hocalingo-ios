//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ COMPLETE REWRITE: Android-style queue management with same-day reviews
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
    @Published var studyQueue: [StudyCard] = []  // ✅ Active queue (like Android)
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var shouldDismiss: Bool = false
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private let jsonLoader = JSONLoader()
    private var currentSessionMaxPosition: Int = 0
    
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
    
    var progressPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentCardIndex) / Double(totalCards)
    }
    
    // MARK: - Init
    init() {
        loadStudySession()
    }
    
    // MARK: - Data Loading
    
    /// Load study session with real data
    func loadStudySession() {
        studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        
        let selectedWordIds = UserDefaultsManager.shared.loadSelectedWords()
        guard !selectedWordIds.isEmpty else {
            print("⚠️ No words selected, loading dummy data")
            loadDummyCards()
            return
        }
        
        guard let packageId = UserDefaultsManager.shared.loadSelectedPackage() else {
            print("⚠️ No package selected, loading dummy data")
            loadDummyCards()
            return
        }
        
        do {
            let vocabularyPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            allWords = vocabularyPackage.words.filter { selectedWordIds.contains($0.id) }
            
            print("✅ Loaded \(allWords.count) words from package: \(packageId)")
            
            loadProgressData()
            createStudyQueue()
            
        } catch {
            print("❌ Error loading vocabulary: \(error)")
            loadDummyCards()
        }
    }
    
    /// Reload session (for new words added)
    func reloadSession() {
        currentCardIndex = 0
        isCardFlipped = false
        loadStudySession()
    }
    
    /// Load progress data for all selected words
    private func loadProgressData() {
        currentProgress = UserDefaultsManager.shared.loadAllProgress()
        currentSessionMaxPosition = currentProgress.values
            .compactMap { $0.sessionPosition }
            .max() ?? 0
        
        print("📊 Loaded progress for \(currentProgress.count) words, maxPosition: \(currentSessionMaxPosition)")
    }
    
    /// ✅ CRITICAL: Create study queue (learning + due review cards)
    private func createStudyQueue() {
        // Filter words that need study
        let dueWords = allWords.filter { word in
            guard let progress = currentProgress[word.id] else {
                return true // New words always included
            }
            return progress.nextReviewAt <= Date()
        }
        
        // ✅ FALLBACK: If no due words, show all selected words
        let wordsToStudy = dueWords.isEmpty ? allWords : dueWords
        
        // Sort by priority
        let sortedWords = wordsToStudy.sorted { word1, word2 in
            let progress1 = currentProgress[word1.id]
            let progress2 = currentProgress[word2.id]
            
            if let p1 = progress1, let p2 = progress2 {
                if p1.learningPhase != p2.learningPhase {
                    return p1.learningPhase
                }
                if p1.learningPhase && p2.learningPhase {
                    let pos1 = p1.sessionPosition ?? 0
                    let pos2 = p2.sessionPosition ?? 0
                    return pos1 < pos2
                }
                return p1.nextReviewAt < p2.nextReviewAt
            }
            return progress1 == nil
        }
        
        // Create queue
        studyQueue = sortedWords.map { word in
            let (front, back) = getCardTexts(for: word)
            return StudyCard(
                id: UUID(),
                wordId: word.id,
                frontText: front,
                backText: back
            )
        }
        
        if dueWords.isEmpty && !allWords.isEmpty {
            print("⚠️ No words due - showing all \(studyQueue.count) selected words")
        } else {
            print("🎴 Created \(studyQueue.count) study cards")
        }
    }
    
    /// Get card texts based on direction
    private func getCardTexts(for word: Word) -> (String, String) {
        switch studyDirection {
        case .enToTr:
            return (word.english, word.turkish)
        case .trToEn:
            return (word.turkish, word.english)
        case .mixed:
            return Bool.random()
            ? (word.english, word.turkish)
            : (word.turkish, word.english)
        }
    }
    
    // MARK: - Actions
    
    func flipCard() {
        isCardFlipped.toggle()
    }
    
    /// ✅ MAIN ACTION: Answer card and manage queue
    func answerCard(difficulty: CardDifficulty) {
        guard currentCardIndex < studyQueue.count else { return }
        
        let card = studyQueue[currentCardIndex]
        
        // Save progress with SM-2 algorithm
        let updatedProgress = saveProgressWithAlgorithm(for: card, difficulty: difficulty)
        
        // Play haptic
        playHapticFeedback(for: difficulty)
        
        // ✅ CRITICAL: Queue management (like Android)
        handleQueueAfterResponse(card: card, progress: updatedProgress, quality: difficulty.quality)
        
        // Reset flip
        isCardFlipped = false
    }
    
    /// ✅ CRITICAL: Handle queue after user response (Android logic)
    private func handleQueueAfterResponse(card: StudyCard, progress: Progress, quality: Int) {
        // Remove current card from queue
        studyQueue.remove(at: currentCardIndex)
        
        // ✅ If still in learning phase → REINSERT into queue
        if progress.learningPhase {
            reinsertCardInQueue(card: card, quality: quality)
        } else {
            print("🎓 Card graduated - removed from queue: wordId=\(card.wordId)")
        }
        
        // Check if queue is empty
        if currentCardIndex >= studyQueue.count {
            handleQueueCompletion()
        }
    }
    
    /// ✅ ANDROID LOGIC: Reinsert card into queue based on quality
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
    
    /// ✅ Handle queue completion (filter learning cards or end session)
    private func handleQueueCompletion() {
        print("🏁 Queue completed at index \(currentCardIndex)")
        
        // ✅ Filter learning phase cards from current progress
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.shouldDismiss = true
        }
    }
    
    /// Save progress with algorithm
    private func saveProgressWithAlgorithm(for card: StudyCard, difficulty: CardDifficulty) -> Progress {
        let wordId = card.wordId
        
        var progress: Progress
        if let existingProgress = currentProgress[wordId] {
            progress = existingProgress
        } else {
            progress = Progress(
                wordId: wordId,
                direction: studyDirection,
                repetitions: 0,
                intervalDays: 0,
                easeFactor: 2.5,
                nextReviewAt: Date(),
                lastReviewAt: nil,
                learningPhase: true,
                sessionPosition: currentSessionMaxPosition + 1,
                successfulReviews: 0,
                hardPresses: 0,
                isSelected: true,
                isMastered: false,
                createdAt: Date(),
                updatedAt: Date()
            )
            currentSessionMaxPosition += 1
        }
        
        let updatedProgress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: difficulty.quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        if updatedProgress.learningPhase, let position = updatedProgress.sessionPosition {
            currentSessionMaxPosition = max(currentSessionMaxPosition, position)
        }
        
        currentProgress[wordId] = updatedProgress
        UserDefaultsManager.shared.saveProgress(updatedProgress, for: wordId)
        UserDefaultsManager.shared.updateStats(wordsStudiedToday: 1)
        
        print("💾 Progress saved: wordId=\(wordId), quality=\(difficulty.quality), nextReview=\(SpacedRepetition.getTimeUntilReview(nextReviewAt: updatedProgress.nextReviewAt))")
        
        return updatedProgress
    }
    
    private func playHapticFeedback(for difficulty: CardDifficulty) {
        let generator = UIImpactFeedbackGenerator()
        switch difficulty {
        case .hard: generator.impactOccurred(intensity: 0.5)
        case .medium: generator.impactOccurred(intensity: 0.7)
        case .easy: generator.impactOccurred(intensity: 1.0)
        }
    }
    
    // MARK: - Dummy Data
    private func loadDummyCards() {
        studyQueue = [
            StudyCard(id: UUID(), wordId: 1, frontText: "Hello", backText: "Merhaba"),
            StudyCard(id: UUID(), wordId: 2, frontText: "Good morning", backText: "Günaydın"),
            StudyCard(id: UUID(), wordId: 3, frontText: "Thank you", backText: "Teşekkür ederim"),
            StudyCard(id: UUID(), wordId: 4, frontText: "How are you?", backText: "Nasılsın?"),
            StudyCard(id: UUID(), wordId: 5, frontText: "I'm fine", backText: "İyiyim")
        ]
    }
}
