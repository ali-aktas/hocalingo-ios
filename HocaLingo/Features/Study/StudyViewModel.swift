//
//  StudyViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Premium ad control added (minimal change)
//  - All original code preserved
//  - Premium users never see ads
//  - Free users see ads every 3rd card
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

class StudyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentCardIndex: Int = 0
    @Published var isCardFlipped: Bool = false
    @Published var studyQueue: [StudyCard] = []
    @Published var studyDirection: StudyDirection = .enToTr
    @Published var cardsCompletedCount: Int = 0
    @Published var showNativeAd: Bool = false
    
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
    
    // ✅ Görünürdeki kartın içeriğini yöneten ana değişken
    @Published var displayCard: StudyCard?
    // ✅ Uygulama açılışında TTS'in tetiklenmesini engelleyen bayrak
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
        observePremiumStatus()  // ✅ NEW: Observe premium status
        loadStudyQueue()
    }
    
    // MARK: - ✅ NEW: Premium Status Observer
    
    /// Observe premium status changes and update ad display
    private func observePremiumStatus() {
        PremiumManager.shared.$isPremium
            .sink { [weak self] _ in
                self?.checkAdDisplay()
            }
            .store(in: &cancellables)
    }
    
    /// Check and update ad display based on premium status and card position
    private func checkAdDisplay() {
        // Premium users NEVER see ads
        if PremiumManager.shared.isPremium {
            showNativeAd = false
            return
        }
        
        // Free users: Show ad every 3rd card (after completing 3, 6, 9, 12... cards)
        if cardsCompletedCount > 0 && cardsCompletedCount % 3 == 0 {
            showNativeAd = true
        } else {
            showNativeAd = false
        }
    }
    
    // MARK: - View Lifecycle Interaction
    
    func onViewAppear() {
        // Ekran gerçekten açıldığında aktif et
        isSessionActive = true
        if studyDirection == .enToTr {
            playCurrentWordAudio()
        }
    }
    
    // MARK: - Logic & Actions
    
    func flipCard() {
        soundManager.playCardFlip()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isCardFlipped.toggle()
        }
        
        // Tr -> En yönünde kart çevrildiğinde (arka yüz İngilizce) otomatik oku
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
        // Sadece oturum aktifse ve henüz okunmadıysa oku
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
        
        // ✅ Track each card studied (5 seconds per card)
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
        // 1. Kartı kapatmaya başla (Kapanma animasyonu)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isCardFlipped = false
        }
        
        self.cardsCompletedCount += 1
        
        // ✅ NEW: Check if ad should be displayed after card completion
        checkAdDisplay()
        
        // 2. ✅ CRITICAL FIX: Filter by time AND learning phase
        let learningWords = allWords.filter { word in
            guard let progress = currentProgress[word.id] else { return false }
            return progress.learningPhase && shouldShowCard(for: word.id)
        }
        
        if learningWords.isEmpty {
            isSessionComplete = true
            return
        }
        
        let sortedWords = prioritizeWordsForStudy(learningWords)
        
        // 3. ✅ RENK GEÇİŞİ: studyQueue'yu hemen güncelle
        // Bu sayede UI'daki renk ve gölge animasyonu pürüzsüzce yeni kartın rengine dönmeye başlar.
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
        
        // 4. ✅ METİN SIZMASI (Leak) ÇÖZÜMÜ: displayCard'ı geciktirerek güncelle
        // Kart tam 90 derecedeyken (görünmezken) metni değiştiriyoruz.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            guard let self = self else { return }
            self.displayCard = self.studyQueue.first
            
            // Eğer EN -> TR ise yeni kartın metni değiştiği an oku
            if self.studyDirection == .enToTr {
                self.playCurrentWordAudio()
            }
        }
    }
    
    // MARK: - Helpers & Data Loading
    
    /// Check if a card should be shown now
    /// ✅ Learning phase: Always show (same-day reviews)
    /// ✅ Review phase: Check nextReviewAt time
    private func shouldShowCard(for wordId: Int) -> Bool {
        guard let progress = currentProgress[wordId] else { return true }
        
        // Learning phase cards ALWAYS show (same-day reviews)
        if progress.learningPhase {
            return true
        }
        
        // Review phase cards: Check time
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

            // ✅ CRITICAL FIX: Filter cards by time (only show cards with nextReviewAt <= now)
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
        let packageFiles = ["en_tr_a1_001", "en_tr_a2_001", "en_tr_b1_001"]
        
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
    
        
    func closeNativeAd() {
        withAnimation { showNativeAd = false }
    }
    
    // MARK: - Study Time Tracking
    private func trackStudyTime() {
        accumulatedSeconds += 5  // Each card = 5 seconds
        print("⏱️ Accumulated seconds: \(accumulatedSeconds)")
        
        // Convert to minutes when we reach 60 seconds
        if accumulatedSeconds >= 60 {
            let minutes = accumulatedSeconds / 60
            userDefaults.addStudyTime(minutes: minutes)
            accumulatedSeconds = accumulatedSeconds % 60  // Keep remainder
            
            print("⏱️ Study time tracked: +\(minutes) min")
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
    
    var currentCardColor: Color {
        // UI'daki renk animasyonunun pürüzsüz olması için studyQueue'dan renk alırız
        let cardForColor = studyQueue.first ?? currentCard
        let colorIndex = abs(cardForColor.wordId) % studyCardColors.count
        return studyCardColors[colorIndex]
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
