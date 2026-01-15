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
    
    // MARK: - Computed Properties
    var currentCard: StudyCard {
        guard !cards.isEmpty, currentCardIndex < cards.count else {
            return StudyCard(id: UUID(), frontText: "No cards", backText: "No cards")
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
        loadDummyCards()
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
        
        // Play haptic feedback based on difficulty
        playHapticFeedback(for: difficulty)
        
        // Move to next card
        moveToNextCard()
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
    
    /// Show completion message (TODO: implement alert)
    private func showCompletionMessage() {
        print("🎉 Study session complete! \(completedCards)/\(totalCards) cards reviewed")
        // TODO: Show completion alert in Day 6
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
    
    // MARK: - Data Loading
    
    /// Load dummy cards for testing
    /// TODO: Replace with real data from selected words in Day 6
    private func loadDummyCards() {
        cards = [
            StudyCard(
                id: UUID(),
                frontText: "Hello",
                backText: "Merhaba"
            ),
            StudyCard(
                id: UUID(),
                frontText: "Good morning",
                backText: "Günaydın"
            ),
            StudyCard(
                id: UUID(),
                frontText: "Thank you",
                backText: "Teşekkür ederim"
            ),
            StudyCard(
                id: UUID(),
                frontText: "How are you?",
                backText: "Nasılsın?"
            ),
            StudyCard(
                id: UUID(),
                frontText: "I'm fine",
                backText: "İyiyim"
            ),
            StudyCard(
                id: UUID(),
                frontText: "See you later",
                backText: "Görüşürüz"
            ),
            StudyCard(
                id: UUID(),
                frontText: "What's your name?",
                backText: "Adın ne?"
            ),
            StudyCard(
                id: UUID(),
                frontText: "My name is...",
                backText: "Benim adım..."
            ),
            StudyCard(
                id: UUID(),
                frontText: "Nice to meet you",
                backText: "Tanıştığıma memnun oldum"
            ),
            StudyCard(
                id: UUID(),
                frontText: "Where are you from?",
                backText: "Nerelisin?"
            )
        ]
    }
    
    /// Load real cards from selected words
    /// TODO: Implement in Day 6
    func loadSelectedWords() {
        // Will load from UserDefaults or CoreData
        // For now, using dummy data
    }
}
