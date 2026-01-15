//
//  StudyViewModel.swift
//  HocaLingo
//
//  Updated on 15.01.2026.
//

import SwiftUI
import Combine

// MARK: - Card Difficulty
enum CardDifficulty {
    case hard
    case medium
    case easy
}

// MARK: - Study Card Model
struct StudyCard {
    let id: UUID
    let wordId: Int
    let frontText: String
    let backText: String
    var isCompleted: Bool = false
}

// MARK: - StudyViewModel
class StudyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCardIndex: Int = 0
    @Published var isCardFlipped: Bool = false
    @Published var cards: [StudyCard] = []
    @Published var studyDirection: StudyDirection = .enToTr
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private let jsonLoader = JSONLoader()
    
    // MARK: - Computed Properties
    var currentCard: StudyCard {
        guard !cards.isEmpty, currentCardIndex < cards.count else {
            return StudyCard(
                id: UUID(),
                wordId: 0,
                frontText: "No cards",
                backText: "No cards"
            )
        }
        return cards[currentCardIndex]
    }
    
    var totalCards: Int {
        return cards.count
    }
    
    var progressPercentage: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentCardIndex) / Double(totalCards)
    }
    
    var completedCards: Int {
        return cards.filter { $0.isCompleted }.count
    }
    
    // MARK: - Init
    init() {
        loadStudySession()
    }
    
    // MARK: - Data Loading
    
    /// Load study session with real data
    func loadStudySession() {
        // Load user settings
        studyDirection = UserDefaultsManager.shared.loadStudyDirection()
        
        // Load selected word IDs
        let selectedWordIds = UserDefaultsManager.shared.loadSelectedWords()
        
        guard !selectedWordIds.isEmpty else {
            print("⚠️ No words selected, loading dummy data")
            loadDummyCards()
            return
        }
        
        // Load selected package ID
        guard let packageId = UserDefaultsManager.shared.loadSelectedPackage() else {
            print("⚠️ No package selected, loading dummy data")
            loadDummyCards()
            return
        }
        
        // Load words from JSON
        do {
            let vocabularyPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            
            // Filter words based on selected IDs
            allWords = vocabularyPackage.words.filter { selectedWordIds.contains($0.id) }
            
            guard !allWords.isEmpty else {
                print("⚠️ No words found, loading dummy data")
                loadDummyCards()
                return
            }
            
            // Load existing progress
            currentProgress = UserDefaultsManager.shared.loadAllProgress()
            
            // Build study queue (words that need review today)
            buildStudyQueue()
            
            print("✅ Loaded \(cards.count) cards for study")
            
        } catch {
            print("❌ Error loading package: \(error.localizedDescription)")
            loadDummyCards()
        }
    }
    
    /// Build study queue based on review dates
    private func buildStudyQueue() {
        let today = Date()
        
        // Filter words that need review today
        let dueWords = allWords.filter { word in
            if let progress = currentProgress[word.id] {
                return progress.nextReviewDate <= today
            } else {
                // New word - add to queue
                return true
            }
        }
        
        // If no words due, show all selected words
        let wordsToStudy = dueWords.isEmpty ? allWords : dueWords
        
        // Convert to StudyCard format
        cards = wordsToStudy.map { word in
            createStudyCard(from: word)
        }
        
        // Shuffle for variety
        cards.shuffle()
    }
    
    /// Create StudyCard from Word based on direction
    private func createStudyCard(from word: Word) -> StudyCard {
        let (front, back) = getCardTexts(for: word)
        
        return StudyCard(
            id: UUID(),
            wordId: word.id,
            frontText: front,
            backText: back
        )
    }
    
    /// Get front and back texts based on study direction
    private func getCardTexts(for word: Word) -> (String, String) {
        switch studyDirection {
        case .enToTr:
            return (word.english, word.turkish)
        case .trToEn:
            return (word.turkish, word.english)
        case .mixed:
            // Randomly pick direction for each card
            return Bool.random() ? (word.english, word.turkish) : (word.turkish, word.english)
        }
    }
    
    // MARK: - Actions
    
    /// Flip the current card
    func flipCard() {
        isCardFlipped.toggle()
    }
    
    /// Answer card with difficulty and move to next
    func answerCard(difficulty: CardDifficulty) {
        // Mark current card as completed
        cards[currentCardIndex].isCompleted = true
        
        // Save progress for this word
        saveProgress(for: currentCard, difficulty: difficulty)
        
        // Play haptic feedback based on difficulty
        playHapticFeedback(for: difficulty)
        
        // Move to next card
        moveToNextCard()
    }
    
    /// Save progress for a word
    private func saveProgress(for card: StudyCard, difficulty: CardDifficulty) {
        let wordId = card.wordId
        
        // Get or create progress
        var progress: Progress
        if let existingProgress = currentProgress[wordId] {
            progress = existingProgress
        } else {
            // Create new progress for first-time word
            progress = Progress(
                id: "\(wordId)_\(studyDirection.rawValue)",
                wordId: wordId,
                direction: studyDirection,
                learningPhase: .learning,
                repetitions: 0,
                easeFactor: 2.5,
                interval: 0,
                nextReviewDate: Date(),
                lastReviewDate: nil,
                totalReviews: 0,
                correctCount: 0,
                incorrectCount: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        
        
        
        // Update progress based on quality
        // NOTE: This is a simple version. Full SM-2 algorithm in Day 8-11
        progress.lastReviewDate = Date()
        progress.repetitions += 1
        progress.totalReviews += 1
        progress.updatedAt = Date()

        switch difficulty {
        case .hard:
            progress.interval = 1 // Review again tomorrow
            progress.easeFactor = max(1.3, progress.easeFactor - 0.2)
            progress.incorrectCount += 1
            
        case .medium:
            progress.interval = max(1, progress.interval * 2)
            progress.easeFactor = max(1.3, progress.easeFactor - 0.1)
            progress.correctCount += 1
            
        case .easy:
            progress.interval = max(4, progress.interval * 2)
            progress.easeFactor = min(2.5, progress.easeFactor + 0.1)
            progress.correctCount += 1
        }

        // Calculate next review date
        progress.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: progress.interval,
            to: Date()
        ) ?? Date()
        
        // Save progress
        currentProgress[wordId] = progress
        UserDefaultsManager.shared.saveProgress(progress, for: wordId)
        
        // Update user stats
        UserDefaultsManager.shared.updateStats(wordsStudiedToday: 1)
    }
    
    /// Move to next card or finish study session
    private func moveToNextCard() {
        // Reset flip state
        isCardFlipped = false
        
        // Check if there are more cards
        if currentCardIndex < cards.count - 1 {
            currentCardIndex += 1
        } else {
            // Study session complete!
            showCompletionMessage()
        }
    }
    
    /// Show completion message
    private func showCompletionMessage() {
        print("🎉 Study session complete! \(completedCards)/\(totalCards) cards reviewed")
        // TODO: Show completion alert in future
    }
    
    /// Play haptic feedback based on difficulty
    private func playHapticFeedback(for difficulty: CardDifficulty) {
        let generator = UIImpactFeedbackGenerator()
        
        switch difficulty {
        case .hard:
            generator.impactOccurred(intensity: 0.5)
        case .medium:
            generator.impactOccurred(intensity: 0.7)
        case .easy:
            generator.impactOccurred(intensity: 1.0)
        }
    }
    
    // MARK: - Dummy Data (Fallback)
    
    /// Load dummy cards for testing
    private func loadDummyCards() {
        cards = [
            StudyCard(
                id: UUID(),
                wordId: 1,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            StudyCard(
                id: UUID(),
                wordId: 2,
                frontText: "Good morning",
                backText: "Günaydın"
            ),
            StudyCard(
                id: UUID(),
                wordId: 3,
                frontText: "Thank you",
                backText: "Teşekkür ederim"
            ),
            StudyCard(
                id: UUID(),
                wordId: 4,
                frontText: "How are you?",
                backText: "Nasılsın?"
            ),
            StudyCard(
                id: UUID(),
                wordId: 5,
                frontText: "I'm fine",
                backText: "İyiyim"
            )
        ]
    }
}
