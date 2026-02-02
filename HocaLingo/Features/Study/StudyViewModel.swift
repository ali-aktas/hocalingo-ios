//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ MINIMAL UPDATE: Card style + Ad suspension (original code preserved)
//  - Reklam sistemi askıya alındı (yorum satırı)
//  - Card style desteği eklendi (minimal)
//  - JSON loading ve tüm diğer mantık ORİJİNAL
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

// MARK: - Card Colors
private let studyCardColors: [Color] = [
    Color(hex: "6366F1"), Color(hex: "8B5CF6"), Color(hex: "EC4899"), Color(hex: "EF4444"),
    Color(hex: "F97316"), Color(hex: "10B981"), Color(hex: "06B6D4"), Color(hex: "3B82F6"),
    Color(hex: "8B5A2B"), Color(hex: "059669"), Color(hex: "7C3AED"), Color(hex: "DC2626"),
    Color(hex: "0891B2"), Color(hex: "065F46"), Color(hex: "7C2D12"), Color(hex: "1E40AF"),
    Color(hex: "7E22CE"), Color(hex: "0F766E"), Color(hex: "A21CAF"), Color(hex: "9A3412")
]

// MARK: - ✅ NEW: Premium Gradients
private let premiumGradients: [[Color]] = [
    // 🌙 DEEP PURPLE & VIOLET FAMILY
    [Color(hex: "4A148C"), Color(hex: "6A1B9A")],  // Deep Purple Night
    [Color(hex: "311B92"), Color(hex: "512DA8")],  // Royal Purple
    [Color(hex: "4527A0"), Color(hex: "5E35B1")],  // Indigo Dream
    [Color(hex: "38006B"), Color(hex: "6A1B9A")],  // Dark Violet
    [Color(hex: "1A237E"), Color(hex: "4A148C")],  // Midnight Purple
    [Color(hex: "4A00E0"), Color(hex: "8E2DE2")],  // Electric Purple
    [Color(hex: "5B247A"), Color(hex: "1BCEDF")],  // Purple to Cyan
    [Color(hex: "360033"), Color(hex: "0B8793")],  // Deep Purple Ocean
    [Color(hex: "622774"), Color(hex: "C53364")],  // Purple to Red
    [Color(hex: "283048"), Color(hex: "859398")],  // Purple Slate
    
    // 🔵 DEEP BLUE & NAVY FAMILY
    [Color(hex: "0D324D"), Color(hex: "7F5A83")],  // Navy to Purple
    [Color(hex: "1565C0"), Color(hex: "0277BD")],  // Deep Blue Ocean
    [Color(hex: "003973"), Color(hex: "E5E5BE")],  // Navy to Gold
    [Color(hex: "141E30"), Color(hex: "243B55")],  // Dark Blue Steel
    [Color(hex: "000046"), Color(hex: "1CB5E0")],  // Midnight Blue
    [Color(hex: "0F2027"), Color(hex: "2C5364")],  // Deep Ocean
    [Color(hex: "1A2980"), Color(hex: "26D0CE")],  // Blue to Cyan
    [Color(hex: "134E5E"), Color(hex: "71B280")],  // Teal Forest
    [Color(hex: "2E3192"), Color(hex: "1BFFFF")],  // Electric Blue
    [Color(hex: "000428"), Color(hex: "004E92")],  // Deep Navy
    
    // 🌊 TEAL & TURQUOISE FAMILY
    [Color(hex: "004E92"), Color(hex: "000428")],  // Deep Teal Night
    [Color(hex: "00695C"), Color(hex: "00897B")],  // Rich Teal
    [Color(hex: "006064"), Color(hex: "00838F")],  // Deep Cyan
    [Color(hex: "004D40"), Color(hex: "00796B")],  // Forest Teal
    [Color(hex: "02AAB0"), Color(hex: "00CDAC")],  // Bright Teal
    [Color(hex: "0B486B"), Color(hex: "F56217")],  // Teal to Orange
    [Color(hex: "136A8A"), Color(hex: "267871")],  // Ocean Teal
    [Color(hex: "085078"), Color(hex: "85D8CE")],  // Deep to Light Teal
    [Color(hex: "00467F"), Color(hex: "A5CC82")],  // Navy to Green
    [Color(hex: "1E3C72"), Color(hex: "2A5298")],  // Midnight Teal
    
    // 🔥 WARM & BOLD FAMILY
    [Color(hex: "B71C1C"), Color(hex: "E53935")],  // Deep Red
    [Color(hex: "BF360C"), Color(hex: "E64A19")],  // Burnt Orange
    [Color(hex: "E65100"), Color(hex: "F57C00")],  // Rich Orange
    [Color(hex: "C62828"), Color(hex: "AD1457")],  // Red to Magenta
    [Color(hex: "880E4F"), Color(hex: "C2185B")],  // Deep Pink
    [Color(hex: "6A1B9A"), Color(hex: "C2185B")],  // Purple to Pink
    [Color(hex: "EC008C"), Color(hex: "FC6767")],  // Vibrant Pink
    [Color(hex: "D31027"), Color(hex: "EA384D")],  // Bold Red
    [Color(hex: "900C3F"), Color(hex: "C70039")],  // Burgundy Red
    [Color(hex: "DA4453"), Color(hex: "89216B")],  // Red to Purple
    
    // 🌲 GREEN & EMERALD FAMILY
    [Color(hex: "1B5E20"), Color(hex: "388E3C")],  // Deep Forest
    [Color(hex: "2E7D32"), Color(hex: "43A047")],  // Rich Green
    [Color(hex: "004D40"), Color(hex: "00796B")],  // Emerald Teal
    [Color(hex: "194D33"), Color(hex: "0C7B93")],  // Forest to Ocean
    [Color(hex: "56AB2F"), Color(hex: "A8E063")],  // Lime Gradient
    [Color(hex: "134E5E"), Color(hex: "71B280")],  // Deep Emerald
    [Color(hex: "0F9B0F"), Color(hex: "000000")],  // Matrix Green
    [Color(hex: "11998E"), Color(hex: "38EF7D")],  // Mint Green
    [Color(hex: "0B8793"), Color(hex: "360033")],  // Teal to Purple
    [Color(hex: "136A8A"), Color(hex: "267871")]   // Ocean Green
]

class StudyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCardIndex: Int = 0
    @Published var isCardFlipped: Bool = false
    @Published var studyQueue: [StudyCard] = []
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var cardsCompletedCount: Int = 0
    
    // ✅ SUSPENDED: Reklam sistemi (gelecek için hazır)
    // @Published var showNativeAd: Bool = false
    
    @Published var isSessionComplete: Bool = false {
        didSet {
            if isSessionComplete && !oldValue {
                NotificationCenter.default.post(
                    name: NSNotification.Name("StudySessionCompleted"),
                    object: nil
                )
                print("📢 Study session completed notification sent")
            }
        }
    }
    
    // ✅ NEW: Card style support
    @Published var cardStyle: CardStyle = .colorful
    @Published var showStyleSettings: Bool = false
    
    @Published var displayCard: StudyCard?
    @Published var isSessionActive: Bool = false
    
    // MARK: - Dependencies
    private let userDefaults = UserDefaultsManager.shared
    private let jsonLoader = JSONLoader()
    private let soundManager = SoundManager.shared
    private let ttsManager = TTSManager.shared
    private var accumulatedSeconds: Int = 0
    
    // MARK: - Private Properties
    private var allWords: [Word] = []
    private var currentProgress: [Int: Progress] = [:]
    private var currentSessionMaxPosition: Int = 0
    private var ttsPlayedForCurrentCard: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        observeDirectionChanges()
        observeWordsChanged()
        // observePremiumStatus()  // ✅ SUSPENDED: Reklam için
        observeCardStyleChanges()  // ✅ NEW
        loadCardStyle()            // ✅ NEW
        loadStudyQueue()
    }
    
    // MARK: - ✅ SUSPENDED: Reklam Sistemi (Kolay Reaktivasyon İçin Hazır)
    /*
    private func observePremiumStatus() {
        PremiumManager.shared.$isPremium
            .sink { [weak self] _ in
                self?.checkAdDisplay()
            }
            .store(in: &cancellables)
    }
    
    private func checkAdDisplay() {
        if PremiumManager.shared.isPremium {
            showNativeAd = false
            return
        }
        
        if cardsCompletedCount > 0 && cardsCompletedCount % 3 == 0 {
            showNativeAd = true
        } else {
            showNativeAd = false
        }
    }
    
    func closeNativeAd() {
        withAnimation { showNativeAd = false }
    }
    */
    
    // MARK: - ✅ NEW: Card Style Management
    
    private func loadCardStyle() {
        cardStyle = userDefaults.loadCardStyle()
    }
    
    private func observeCardStyleChanges() {
        NotificationCenter.default.publisher(for: NSNotification.Name("CardStyleChanged"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.cardStyle = UserDefaultsManager.shared.loadCardStyle()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - View Lifecycle (ORİJİNAL)
    
    func onViewAppear() {
        isSessionActive = true
        if studyDirection == .enToTr {
            playCurrentWordAudio()
        }
    }
    
    // MARK: - Logic & Actions (ORİJİNAL)
    
    func flipCard() {
        soundManager.playCardFlip()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
        
        if isCardFlipped && studyDirection == .trToEn {
            playCurrentWordAudio()
        }
    }
    
    func replayAudio() {
        guard let card = displayCard else { return }
        if let word = allWords.first(where: { $0.id == card.wordId }) {
            ttsManager.speakEnglishWord(word.english)
        }
    }
    
    private func playCurrentWordAudio() {
        guard isSessionActive, let card = displayCard else { return }
        guard let word = allWords.first(where: { $0.id == card.wordId }) else { return }
        
        if !ttsPlayedForCurrentCard {
            ttsManager.speakEnglishWord(word.english)
            ttsPlayedForCurrentCard = true
        }
    }
    
    func answerCard(difficulty: CardDifficulty) {
        guard displayCard != nil else { return }
        soundManager.playClickSound()
        handleStudyResponse(difficulty: difficulty)
    }
    
    private func handleStudyResponse(difficulty: CardDifficulty) {
        guard let currentCard = displayCard else { return }
        guard var progress = currentProgress[currentCard.wordId] else { return }
        
        let newProgress = SpacedRepetition.calculateNextReview(
            currentProgress: progress,
            quality: difficulty.quality,
            currentSessionMaxPosition: currentSessionMaxPosition
        )
        
        userDefaults.saveProgress(newProgress, for: currentCard.wordId, direction: studyDirection)
        currentProgress[currentCard.wordId] = newProgress
        
        userDefaults.incrementCardsStudied()
        trackStudyTime()
        
        if let position = newProgress.sessionPosition, position > currentSessionMaxPosition {
            currentSessionMaxPosition = position
        }
        
        if progress.learningPhase && !newProgress.learningPhase {
            userDefaults.incrementDailyGraduations()
            print("🎓 Word graduated! Daily stats updated.")
        }
        
        requeueAndContinue()
    }

    private func requeueAndContinue() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
        }
        
        self.cardsCompletedCount += 1
        
        // ✅ SUSPENDED: checkAdDisplay()
        
        let learningWords = allWords.filter { word in
            guard let progress = currentProgress[word.id] else { return false }
            return progress.learningPhase && shouldShowCard(for: word.id)
        }
        
        if learningWords.isEmpty {
            isSessionComplete = true
            return
        }
        
        let sortedWords = prioritizeWordsForStudy(learningWords)
        
        self.studyQueue = sortedWords.map { word in
            StudyCard(
                id: UUID(),
                wordId: word.id,
                frontText: getFrontText(for: word),
                backText: getBackText(for: word)
            )
        }
        self.currentCardIndex = 0
        self.ttsPlayedForCurrentCard = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            guard let self = self else { return }
            self.displayCard = self.studyQueue.first
            
            if self.studyDirection == .enToTr {
                self.playCurrentWordAudio()
            }
        }
    }
    
    // MARK: - Helpers & Data Loading (ORİJİNAL - DOKUNMADIM!)
    
    private func shouldShowCard(for wordId: Int) -> Bool {
        guard let progress = currentProgress[wordId] else { return true }
        
        if progress.learningPhase {
            return true
        }
        
        return progress.nextReviewAt <= Date()
    }
    
    func loadStudyQueue() {
        studyDirection = userDefaults.loadStudyDirection()
        do {
            allWords = try loadAllSelectedWords()
            guard !allWords.isEmpty else {
                studyQueue = []
                displayCard = nil
                isSessionComplete = true
                return
            }
            loadOrCreateProgressForWords()
            currentSessionMaxPosition = calculateMaxSessionPosition()

            let availableWords = allWords.filter { shouldShowCard(for: $0.id) }
            let sortedWords = prioritizeWordsForStudy(availableWords)
            
            studyQueue = sortedWords.map { word in
                StudyCard(
                    id: UUID(),
                    wordId: word.id,
                    frontText: getFrontText(for: word),
                    backText: getBackText(for: word)
                )
            }
            currentCardIndex = 0
            displayCard = studyQueue.first
            isSessionComplete = studyQueue.isEmpty
            cardsCompletedCount = 0
            
        } catch {
            studyQueue = []
            isSessionComplete = true
        }
    }
    
    private func observeDirectionChanges() {
        NotificationCenter.default.publisher(for: NSNotification.Name("StudyDirectionChanged"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.studyDirection = UserDefaultsManager.shared.loadStudyDirection()
                self.loadStudyQueue()
            }
            .store(in: &cancellables)
    }
    
    private func observeWordsChanged() {
        NotificationCenter.default.publisher(for: NSNotification.Name("WordsChanged"))
            .sink { [weak self] _ in
                self?.loadStudyQueue()
            }
            .store(in: &cancellables)
    }

    private func loadOrCreateProgressForWords() {
        currentProgress.removeAll()
        for word in allWords {
            if let existingProgress = userDefaults.loadProgress(for: word.id, direction: studyDirection) {
                currentProgress[word.id] = existingProgress
            } else {
                let newProgress = Progress(wordId: word.id, direction: studyDirection)
                userDefaults.saveProgress(newProgress, for: word.id, direction: studyDirection)
                currentProgress[word.id] = newProgress
            }
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
        let packageFiles = ["standard_a1_001", "standard_a1_002", "standard_b1_001"]
        
        for packageId in packageFiles {
            if let package = try? jsonLoader.loadVocabularyPackage(filename: packageId) {
                let selectedFromPackage = package.words.filter { selectedIds.contains($0.id) }
                loadedWords.append(contentsOf: selectedFromPackage)
            }
        }
        
        let userWords = userDefaults.loadUserAddedWords()
        let selectedUserWords = userWords.filter { selectedIds.contains($0.id) }
        loadedWords.append(contentsOf: selectedUserWords)
        
        return loadedWords
    }

    private func calculateMaxSessionPosition() -> Int {
        let learningProgress = currentProgress.values.filter { $0.learningPhase }
        return learningProgress.map { $0.sessionPosition ?? 0 }.max() ?? 0
    }
    
    private func trackStudyTime() {
        accumulatedSeconds += 5
        
        if accumulatedSeconds >= 60 {
            let minutes = accumulatedSeconds / 60
            userDefaults.addStudyTime(minutes: minutes)
            accumulatedSeconds = accumulatedSeconds % 60
        }
    }

    // MARK: - Computed Properties
    
    var currentCard: StudyCard {
        displayCard ?? studyQueue.first ?? StudyCard(id: UUID(), wordId: 0, frontText: "", backText: "")
    }

    var shouldShowSpeakerOnFront: Bool {
        return studyDirection == .enToTr
    }
    
    var hardTimeText: String { getCurrentTimeText(for: .hard) }
    var mediumTimeText: String { getCurrentTimeText(for: .medium) }
    var easyTimeText: String { getCurrentTimeText(for: .easy) }
    
    // ✅ UPDATED: Card color based on style
    var currentCardColor: Color {
        let cardForColor = studyQueue.first ?? currentCard
        let colorIndex = abs(cardForColor.wordId) % studyCardColors.count
        
        switch cardStyle {
        case .colorful:
            return studyCardColors[colorIndex]
        case .minimal:
            return Color(hex: "9CA3AF")
        case .premium:
            let gradientIndex = abs(cardForColor.wordId) % premiumGradients.count
            return premiumGradients[gradientIndex][0]
        }
    }
    
    // ✅ NEW: Premium gradient support
    var currentCardGradient: [Color]? {
        if cardStyle == .minimal {
            return [Color(hex: "141E30"), Color(hex: "243B55")]
        }
        
        guard cardStyle == .premium else { return nil }
        
        let cardForColor = studyQueue.first ?? currentCard
        let gradientIndex = abs(cardForColor.wordId) % premiumGradients.count
        return premiumGradients[gradientIndex]
    }
    
    var currentExampleSentence: String {
        guard let word = allWords.first(where: { $0.id == currentCard.wordId }) else { return "" }
        switch studyDirection {
        case .enToTr: return isCardFlipped ? word.example.tr : word.example.en
        case .trToEn: return isCardFlipped ? word.example.en : word.example.tr
        }
    }
    
    private func getCurrentTimeText(for difficulty: CardDifficulty) -> String {
        guard let progress = currentProgress[currentCard.wordId] else { return "Soon" }
        return progress.getButtonTimeText(quality: difficulty.quality)
    }
    
    private func getFrontText(for word: Word) -> String {
        studyDirection == .enToTr ? word.english : word.turkish
    }
    
    private func getBackText(for word: Word) -> String {
        studyDirection == .enToTr ? word.turkish : word.english
    }
}
