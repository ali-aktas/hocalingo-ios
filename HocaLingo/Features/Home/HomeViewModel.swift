//
//  HomeViewModel.swift
//  HocaLingo
//
//  ✅ FIXED: Brace structure corrected (loadMonthlyStats was nested inside loadDashboardData)
//  ✅ FIXED: L() helper used for reactive localization
//  Location: HocaLingo/Features/Home/HomeViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Home View Model
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var uiState = HomeUiState()
    @Published var shouldNavigateToStudy: Bool = false
    @Published var shouldNavigateToPackageSelection: Bool = false
    @Published var shouldNavigateToAIAssistant: Bool = false
    @Published var shouldShowAddWordDialog: Bool = false
    @Published var currentContentType: HeroContentType = .image(0)

    // MARK: - Motivation Text Keys
    private let motivationTextKeys = [
        "motivation_1",  "motivation_2",  "motivation_3",  "motivation_4",  "motivation_5",
        "motivation_6",  "motivation_7",  "motivation_8",  "motivation_9",  "motivation_10",
        "motivation_11", "motivation_12", "motivation_13", "motivation_14", "motivation_15",
        "motivation_16", "motivation_17", "motivation_18", "motivation_19", "motivation_20"
    ]

    // MARK: - Rotation Sequence
    private let rotationSequence: [HeroContentType] = [
        .image(0), .text(0),  .text(1),  .text(2),
        .image(1), .text(3),  .text(4),  .text(5),
        .image(2), .text(6),  .text(7),  .text(8),  .text(9),
        .image(3), .text(10), .text(11), .text(12), .text(13),
        .image(4), .text(14), .text(15), .text(16), .text(17),
        .image(5), .text(18), .text(19)
    ]

    private var currentRotationIndex = 0

    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    private let soundManager = SoundManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        loadDashboardData()
        checkPremiumStatus()
        currentContentType = rotationSequence[0]
    }

    // MARK: - Computed Properties

    /// Greeting text based on time of day — uses L() for reactive localization
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return L("home_greeting_morning")
        case 12..<17: return L("home_greeting_afternoon")
        case 17..<22: return L("home_greeting_evening")
        default:      return L("home_greeting_night")
        }
    }

    /// Get motivation text by index — uses L() for reactive localization
    func getMotivationText(for index: Int) -> String {
        guard index < motivationTextKeys.count else { return "" }
        return L(motivationTextKeys[index])
    }

    // MARK: - Hero Content Rotation
    func rotateHeroContent() {
        currentRotationIndex = (currentRotationIndex + 1) % rotationSequence.count
        currentContentType = rotationSequence[currentRotationIndex]
    }

    // MARK: - Data Loading

    func loadDashboardData() {
        DispatchQueue.main.async {
            self.uiState.isLoading = true

            let userDefaults = UserDefaultsManager.shared

            // 1. Basic User Data
            self.uiState.userName = userDefaults.loadUserName() ?? "Student"

            // 2. Daily Goal Progress
            let todayStats = userDefaults.getTodayDailyStats()
            let dailyGoal = userDefaults.loadDailyGoal()
            self.uiState.dailyGoalProgress = DailyGoalProgress(
                currentWords: todayStats.wordsGraduated,
                targetWords: dailyGoal
            )

            // 3. Monthly Stats
            self.loadMonthlyStats()

            // 4. Learned Words Count (21+ day interval)
            self.uiState.streakDays = userDefaults.calculateTotalLearnedWords()

            // 5. Current Streak
            let userStats = userDefaults.loadUserStats()
            self.uiState.currentStreak = userStats.currentStreak

            self.uiState.isLoading = false

            print("📊 Dashboard loaded: learned=\(self.uiState.streakDays) streak=\(self.uiState.currentStreak)")
        }
    }

    // MARK: - Monthly Stats (separate function — NOT nested inside loadDashboardData)
    private func loadMonthlyStats() {
        let calendar = Calendar.current
        let now = Date()

        // Today's minutes
        let todayString = getLocalDateString(from: now)
        let todayStats = userDefaults.loadDailyStats(for: todayString)
        let minutesToday = todayStats?.studyTimeMinutes ?? 0

        // Month total
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return }
        var totalMinutesMonth = 0
        var currentDate = monthStart

        while currentDate <= now {
            let dateString = getLocalDateString(from: currentDate)
            if let dayStats = userDefaults.loadDailyStats(for: dateString) {
                totalMinutesMonth += dayStats.studyTimeMinutes
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        // Active days & discipline score
        let activeDays = userDefaults.getMonthlyStudiedDaysCount()
        let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        let disciplineScore = min(100, Int((Double(activeDays) / Double(daysInMonth)) * 100))

        DispatchQueue.main.async {
            self.uiState.monthlyStats = MonthlyStats(
                studyTimeToday: minutesToday,
                studyTimeThisMonth: totalMinutesMonth,
                activeDaysThisMonth: activeDays,
                disciplineScore: disciplineScore
            )
        }
    }

    // MARK: - Helpers
    private func getLocalDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    private func checkPremiumStatus() {
        uiState.isPremium = PremiumManager.shared.isPremium
    }

    // MARK: - Event Handling
    func onEvent(_ event: HomeEvent) {
        switch event {
        case .loadDashboardData:       loadDashboardData()
        case .refreshData:             refreshData()
        case .startStudy:              handleStartStudy()
        case .navigateToPackageSelection: handleNavigateToPackageSelection()
        case .navigateToAIAssistant:   handleNavigateToAIAssistant()
        case .showAddWordDialog:       handleShowAddWordDialog()
        case .dismissPremiumPush:      break
        case .premiumPurchaseSuccess:  break
        }
    }

    // MARK: - Navigation Handlers
    private func handleStartStudy() {
        soundManager.playClickSound()
        shouldNavigateToStudy = true
    }

    private func handleNavigateToPackageSelection() {
        soundManager.playClickSound()
        shouldNavigateToPackageSelection = true
    }

    private func handleNavigateToAIAssistant() {
        soundManager.playClickSound()
        shouldNavigateToAIAssistant = true
    }

    private func handleShowAddWordDialog() {
        soundManager.playClickSound()
        shouldShowAddWordDialog = true
    }

    private func refreshData() {
        loadDashboardData()
    }
}

// MARK: - Hero Content Type
enum HeroContentType: Equatable {
    case image(Int)
    case text(Int)
}
