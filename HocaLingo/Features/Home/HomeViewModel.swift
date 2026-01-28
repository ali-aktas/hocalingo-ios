//
//  HomeViewModel.swift
//  HocaLingo
//
//  ✅ FIXED: All compilation errors resolved
//  - Removed redeclarations (HomeUiState, DailyGoalProgress, MonthlyStats, HomeEvent)
//  - Fixed SoundManager calls (playClickSound instead of playSound)
//  - Removed non-existent UserDefaultsManager methods
//  - Simplified monthly stats calculation
//
//  Location: HocaLingo/Features/Home/HomeViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Home View Model
/// Business logic for home dashboard - production-grade with Android parity
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var uiState = HomeUiState()
    
    // ✅ NEW: Navigation triggers
    @Published var shouldNavigateToStudy: Bool = false
    @Published var shouldNavigateToPackageSelection: Bool = false
    @Published var shouldNavigateToAIAssistant: Bool = false
    @Published var shouldShowAddWordDialog: Bool = false
    
    // ✅ NEW: Current content type (image or text)
    @Published var currentContentType: HeroContentType = .image(0)
    
    // MARK: - Motivational Texts (Localized Keys)
    /// 10 motivation text keys - will be localized
    private let motivationTextKeys = [
        "motivation_1",  // Just 10 minutes a day...
        "motivation_2",  // You'll see how easy English is...
        "motivation_3",  // Small steps, big goals
        "motivation_4",  // Every word brings you closer
        "motivation_5",  // Practice makes perfect
        "motivation_6",  // Your English journey continues
        "motivation_7",  // Today is a great day to learn
        "motivation_8",  // Success comes with patience
        "motivation_9",  // Welcome to the world of English
        "motivation_10"  // Keep the momentum going!
    ]
    
    // ✅ ROTATION SEQUENCE: [image, text, text, text, image, text, text, text, image, text, text, text, text]
    // Total: 13 items (40 seconds each = 8.6 minutes full cycle)
    private let rotationSequence: [HeroContentType] = [
        .image(0),      // lingohoca1
        .text(0),       // motivation_1
        .text(1),       // motivation_2
        .text(2),       // motivation_3
        .image(1),      // lingohoca2
        .text(3),       // motivation_4
        .text(4),       // motivation_5
        .text(5),       // motivation_6
        .image(2),      // lingohoca3
        .text(6),       // motivation_7
        .text(7),       // motivation_8
        .text(8),       // motivation_9
        .text(9)        // motivation_10
    ]
    
    private var currentRotationIndex = 0
    
    // MARK: - Computed Properties
    
    /// Greeting text based on time of day (localized)
    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return NSLocalizedString("home_greeting_morning", comment: "")
        case 12..<17:
            return NSLocalizedString("home_greeting_afternoon", comment: "")
        case 17..<22:
            return NSLocalizedString("home_greeting_evening", comment: "")
        default:
            return NSLocalizedString("home_greeting_night", comment: "")
        }
    }
    
    /// Get current motivation text (localized)
    func getMotivationText(for index: Int) -> String {
        guard index < motivationTextKeys.count else { return "" }
        return NSLocalizedString(motivationTextKeys[index], comment: "")
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaultsManager.shared
    private let soundManager = SoundManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadDashboardData()
        checkPremiumStatus()
        
        // Set initial content
        currentContentType = rotationSequence[0]
    }
    
    // MARK: - Hero Content Rotation
    
    /// Rotate to next content (called every 40 seconds)
    func rotateHeroContent() {
        currentRotationIndex = (currentRotationIndex + 1) % rotationSequence.count
        currentContentType = rotationSequence[currentRotationIndex]
    }
    
    // MARK: - Data Loading
        
        /// Dashboard verilerini yükleyen ana fonksiyon
        func loadDashboardData() {
            uiState.isLoading = true
            
            // 1. Temel Kullanıcı Verileri
            uiState.userName = userDefaults.loadUserName() ?? "Student"
            
            // 2. Günlük Hedef İlerlemesi (Bugünkü Mezun Olan Kelimeler)
            let todayStats = userDefaults.getTodayDailyStats()
            let dailyGoal = userDefaults.loadDailyGoal()
            uiState.dailyGoalProgress = DailyGoalProgress(
                currentWords: todayStats.wordsGraduated,
                targetWords: dailyGoal
            )
            
            // 3. İstatistikleri ve Süreleri Hesapla
            loadMonthlyStats()
            
            // 4. Öğrenilen Kelime Sayısı (21+ gün barajı)
            // streakDays alanı isimlendirme olarak kalsa da değerini Learned Words'den alıyor
            uiState.streakDays = userDefaults.calculateTotalLearnedWords()
            
            uiState.isLoading = false
        }
        
        /// Çalışma sürelerini ve aylık verileri hesaplayan fonksiyon
        private func loadMonthlyStats() {
            let calendar = Calendar.current
            let now = Date()
            let todayString = getLocalDateString(from: now)
            
            // 1. Bugünün süresini direkt UserDefaults'tan çek
            let todayStats = userDefaults.loadDailyStats(for: todayString)
            let minutesToday = todayStats?.studyTimeMinutes ?? 0
            
            // 2. Ayın toplamını hesapla (Döngü ile günleri tara)
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
            
            // 3. Aktif gün sayısını al (Herhangi bir aktivite olan günler)
            let activeDays = userDefaults.getMonthlyStudiedDaysCount()
            
            // 4. Disiplin skorunu hesapla (Aktif Günler / Ayın Toplam Günü)
            let daysInMonth = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
            let disciplineScore = min(100, Int((Double(activeDays) / Double(daysInMonth)) * 100))
            
            // UI State Güncelleme
            DispatchQueue.main.async {
                self.uiState.monthlyStats = MonthlyStats(
                    studyTimeToday: minutesToday,
                    studyTimeThisMonth: totalMinutesMonth,
                    activeDaysThisMonth: activeDays,
                    disciplineScore: disciplineScore
                )
            }
        }
        
        // MARK: - Helpers (Scope hatalarını çözen kısımlar)
        
        /// Cihazın yerel saat dilimine göre tarih stringi üretir (Timezone hatasını çözer)
        private func getLocalDateString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = .current
            return formatter.string(from: date)
        }

        /// Premium durum kontrolü (Gelecekte eklenecek)
        private func checkPremiumStatus() {
            uiState.isPremium = false
        }
    
    // MARK: - Event Handling
    
    func onEvent(_ event: HomeEvent) {
        switch event {
        case .loadDashboardData:
            loadDashboardData()
            
        case .refreshData:
            refreshData()
            
        case .startStudy:
            handleStartStudy()
            
        case .navigateToPackageSelection:
            handleNavigateToPackageSelection()
            
        case .navigateToAIAssistant:
            handleNavigateToAIAssistant()
            
        case .showAddWordDialog:
            handleShowAddWordDialog()
            
        // ✅ EKLE: Eksik case'ler
        case .dismissPremiumPush:
            // Premium push kapatma (şimdilik boş bırak)
            break
            
        case .premiumPurchaseSuccess:
            // Premium satın alma başarılı (şimdilik boş bırak)
            break
        }
    }
    // MARK: - Navigation Handlers
    
    private func handleStartStudy() {
        soundManager.playClickSound()  // ✅ FIXED: Use playClickSound() instead of playSound(.buttonTap)
        shouldNavigateToStudy = true
    }
    
    private func handleNavigateToPackageSelection() {
        soundManager.playClickSound()  // ✅ FIXED
        shouldNavigateToPackageSelection = true
    }
    
    private func handleNavigateToAIAssistant() {
        soundManager.playClickSound()  // ✅ FIXED
        shouldNavigateToAIAssistant = true
    }
    
    private func handleShowAddWordDialog() {
        soundManager.playClickSound()  // ✅ FIXED
        shouldShowAddWordDialog = true
    }
    
    private func refreshData() {
        loadDashboardData()
    }
}

// MARK: - Hero Content Type
/// Defines what content to show in hero card (image or motivation text)
enum HeroContentType: Equatable {
    case image(Int)  // Image index (0, 1, 2)
    case text(Int)   // Motivation text index (0-9)
}

// ✅ REMOVED: HomeEvent, HomeUiState, DailyGoalProgress, MonthlyStats
// These are already defined in HomeUiState.swift - no redeclaration
