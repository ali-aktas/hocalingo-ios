//
//  HardWordsQuizViewModel.swift
//  HocaLingo
//
//  Hard Words Quiz - ViewModel & Logic
//  Premium feature: 3-option quiz for words with 5+ hard presses
//  Location: Features/HardWordsQuiz/HardWordsQuizViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Quiz Constants
private enum QuizConstants {
    static let hardPressThreshold = 5       // Min hard presses to enter quiz
    static let graduationCorrectCount = 5   // Total correct answers to graduate
    static let optionCount = 3              // Number of options per question
}

// MARK: - Quiz Option
struct QuizOption: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
}

// MARK: - Quiz Question
struct QuizQuestion: Identifiable {
    let id = UUID()
    let wordId: Int
    let english: String
    let correctTurkish: String
    let allMeanings: String          // For display after answer
    let options: [QuizOption]
}

// MARK: - Quiz Answer Result
enum QuizAnswerState: Equatable {
    case unanswered
    case correct
    case wrong(correctAnswer: String)
}

// MARK: - Quiz Session State
enum QuizSessionState {
    case playing
    case sessionComplete
}

// MARK: - Session Stats
struct QuizSessionStats {
    var totalQuestions: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0
    var graduatedWords: [String] = []    // English names of graduated words
    var streak: Int = 0
    var bestStreak: Int = 0
}

// MARK: - Quiz ViewModel
class HardWordsQuizViewModel: ObservableObject {

    // MARK: - Published State
    @Published var currentQuestion: QuizQuestion?
    @Published var answerState: QuizAnswerState = .unanswered
    @Published var sessionState: QuizSessionState = .playing
    @Published var stats = QuizSessionStats()
    @Published var currentIndex: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var selectedOptionId: UUID? = nil

    // MARK: - Private
    private var questions: [QuizQuestion] = []
    private var allPoolWords: [Word] = []       // All words for wrong option generation
    private let userDefaults = UserDefaultsManager.shared
    private let jsonLoader = JSONLoader()
    private let soundManager = SoundManager.shared
    private let quizCorrectPrefix = "quiz_correct_"

    // MARK: - Init
    init() {
        loadQuizData()
    }

    // MARK: - Load Data
    func loadQuizData() {
        let direction = userDefaults.loadStudyDirection()
        var hardWords: [Word] = []
        var allWords: [Word] = []
        var seenIds = Set<Int>()

        // Discover all packages
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("package_") && $0.hasSuffix("_selected") }

        for key in allKeys {
            let packageId = String(key.dropFirst("package_".count).dropLast("_selected".count))
            guard let package = try? jsonLoader.loadVocabularyPackage(filename: packageId) else { continue }
            let selectedIds = Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])

            for word in package.words {
                if selectedIds.contains(word.id) && !seenIds.contains(word.id) {
                    seenIds.insert(word.id)
                    allWords.append(word)

                    // Check hard presses threshold
                    if let progress = userDefaults.loadProgress(for: word.id, direction: direction) {
                        let hp = progress.hardPresses ?? 0
                        let quizCorrect = getQuizCorrectCount(for: word.id)
                        if hp >= QuizConstants.hardPressThreshold && quizCorrect < QuizConstants.graduationCorrectCount {
                            hardWords.append(word)
                        }
                    }
                }
            }
        }

        // Also check user-added words
        for word in userDefaults.loadUserAddedWords() where !seenIds.contains(word.id) {
            seenIds.insert(word.id)
            allWords.append(word)
            if let progress = userDefaults.loadProgress(for: word.id, direction: direction) {
                let hp = progress.hardPresses ?? 0
                let quizCorrect = getQuizCorrectCount(for: word.id)
                if hp >= QuizConstants.hardPressThreshold && quizCorrect < QuizConstants.graduationCorrectCount {
                    hardWords.append(word)
                }
            }
        }

        allPoolWords = allWords
        questions = generateQuestions(from: hardWords.shuffled())
        totalQuestions = questions.count
        stats.totalQuestions = questions.count
        currentIndex = 0

        if questions.isEmpty {
            sessionState = .sessionComplete
        } else {
            currentQuestion = questions.first
            sessionState = .playing
        }
    }

    // MARK: - Generate Questions
    private func generateQuestions(from hardWords: [Word]) -> [QuizQuestion] {
        return hardWords.compactMap { word in
            let correctAnswer = word.turkish  // Primary meaning
            let wrongOptions = generateWrongOptions(for: word, count: QuizConstants.optionCount - 1)

            guard wrongOptions.count == QuizConstants.optionCount - 1 else { return nil }

            var options = [QuizOption(text: correctAnswer, isCorrect: true)]
            options.append(contentsOf: wrongOptions.map { QuizOption(text: $0, isCorrect: false) })
            options.shuffle()

            return QuizQuestion(
                wordId: word.id,
                english: word.english,
                correctTurkish: correctAnswer,
                allMeanings: word.allTurkishMeanings,
                options: options
            )
        }
    }

    private func generateWrongOptions(for targetWord: Word, count: Int) -> [String] {
        // Collect candidate wrong answers from same level
        let targetLevel = targetWord.level
        var candidates = allPoolWords
            .filter { $0.id != targetWord.id && $0.level == targetLevel }
            .map { $0.turkish }

        // If not enough same-level, expand to all words
        if candidates.count < count {
            candidates = allPoolWords
                .filter { $0.id != targetWord.id }
                .map { $0.turkish }
        }

        // Remove duplicates and any that match the correct answer
        let correctAnswers = Set(targetWord.meanings.map { $0.turkish })
        candidates = Array(Set(candidates).subtracting(correctAnswers))

        guard candidates.count >= count else { return [] }
        return Array(candidates.shuffled().prefix(count))
    }

    // MARK: - Answer Question
    func selectOption(_ option: QuizOption) {
        guard answerState == .unanswered, let question = currentQuestion else { return }
        selectedOptionId = option.id

        if option.isCorrect {
            answerState = .correct
            stats.correctCount += 1
            stats.streak += 1
            if stats.streak > stats.bestStreak { stats.bestStreak = stats.streak }
            soundManager.playSuccess()

            // Increment quiz correct count
            incrementQuizCorrect(for: question.wordId)

            // Check graduation
            if getQuizCorrectCount(for: question.wordId) >= QuizConstants.graduationCorrectCount {
                graduateWord(question.wordId, english: question.english)
            }
        } else {
            answerState = .wrong(correctAnswer: question.correctTurkish)
            stats.wrongCount += 1
            stats.streak = 0
            soundManager.playWrong()

            // Reset quiz correct count on wrong answer
            resetQuizCorrect(for: question.wordId)
        }
    }

    // MARK: - Next Question
    func nextQuestion() {
        let nextIndex = currentIndex + 1

        if nextIndex >= questions.count {
            sessionState = .sessionComplete
            soundManager.playClickSound()
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex = nextIndex
            currentQuestion = questions[nextIndex]
            answerState = .unanswered
            selectedOptionId = nil
        }
    }

    // MARK: - New Session (Continue Studying)
    func startNewSession() {
        answerState = .unanswered
        selectedOptionId = nil
        stats = QuizSessionStats()
        loadQuizData()
    }

    // MARK: - Quiz Correct Tracking (UserDefaults)
    private func getQuizCorrectCount(for wordId: Int) -> Int {
        UserDefaults.standard.integer(forKey: "\(quizCorrectPrefix)\(wordId)")
    }

    private func incrementQuizCorrect(for wordId: Int) {
        let key = "\(quizCorrectPrefix)\(wordId)"
        let current = UserDefaults.standard.integer(forKey: key)
        UserDefaults.standard.set(current + 1, forKey: key)
    }

    private func resetQuizCorrect(for wordId: Int) {
        let key = "\(quizCorrectPrefix)\(wordId)"
        UserDefaults.standard.set(0, forKey: key)
    }

    private func clearQuizCorrect(for wordId: Int) {
        UserDefaults.standard.removeObject(forKey: "\(quizCorrectPrefix)\(wordId)")
    }

    // MARK: - Graduation
    private func graduateWord(_ wordId: Int, english: String) {
        stats.graduatedWords.append(english)

        // Reset hardPresses in Progress
        let direction = userDefaults.loadStudyDirection()
        if var progress = userDefaults.loadProgress(for: wordId, direction: direction) {
            progress.hardPresses = 0
            userDefaults.saveProgress(progress, for: wordId, direction: direction)
        }

        // Clear quiz tracking
        clearQuizCorrect(for: wordId)

        print("🎓 Word graduated from hard list: \(english)")
    }

    // MARK: - Computed
    var progressFraction: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalQuestions)
    }

    var hasHardWords: Bool { !questions.isEmpty }
}
