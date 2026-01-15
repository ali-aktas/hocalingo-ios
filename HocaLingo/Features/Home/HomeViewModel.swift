//
//  HomeViewModel.swift
//  HocaLingo
//
//  Updated on 15.01.2026.
//

import SwiftUI
import Combine

// MARK: - Home View Model
/// Business logic for home screen - EXACTLY matches HomeView requirements
/// Location: HocaLingo/Features/Home/HomeViewModel.swift
class HomeViewModel: ObservableObject {
    
    // MARK: - Published Properties (EXACTLY as HomeView expects)
    @Published var greetingText: String = ""
    @Published var motivationText: String = ""
    @Published var streakDays: Int = 0
    @Published var todaysWords: Int = 0
    @Published var totalLearned: Int = 0
    
    // MARK: - Private Properties
    private let motivationTexts = [
        "Your English adventure awaits",
        "New words, new opportunities",
        "You're one step closer to your goal",
        "What story will you write today?",
        "Motivation is high, let's start",
        "Success comes with patience, keep going",
        "Every study session is a victory",
        "Ready to learn today?",
        "Welcome to the world of English"
    ]
    
    // MARK: - Initialization
    init() {
        loadDashboardData()
    }
    
    // MARK: - Data Loading
    private func loadDashboardData() {
        // Generate greeting based on time
        greetingText = generateGreeting()
        
        // Select daily motivation (rotate by day of year)
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        motivationText = motivationTexts[dayOfYear % motivationTexts.count]
        
        // Load real user stats from UserDefaults
        loadUserStats()
    }
    
    /// Load real user stats
    private func loadUserStats() {
        let stats = UserDefaultsManager.shared.loadUserStats()
        
        streakDays = stats.currentStreak
        todaysWords = stats.totalWordsStudied
        totalLearned = stats.wordsLearned
        
        print("📊 Loaded stats: streak=\(streakDays), today=\(todaysWords), total=\(totalLearned)")
    }
    
    /// Generate greeting based on time
    private func generateGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning! ☀️"
        case 12..<17:
            return "Good Afternoon! 🌤️"
        case 17..<22:
            return "Good Evening! 🌙"
        default:
            return "Good Night! ✨"
        }
    }
    
    // MARK: - Actions (EXACTLY as HomeView calls them)
    
    /// Start study session - called by HomeView play button
    func startStudy() {
        let selectedWordsCount = UserDefaultsManager.shared.loadSelectedWords().count
        
        if selectedWordsCount > 0 {
            print("✅ Starting study session with \(selectedWordsCount) words")
            // Navigation will be handled by parent view
        } else {
            print("⚠️ No words selected. Navigate to package selection.")
            // Show alert or navigate to package selection
        }
    }
    
    /// Refresh data (call after returning from study)
    func refreshData() {
        loadDashboardData()
    }
    
    /// Update stats after study session
    func updateAfterStudy(wordsLearned: Int) {
        todaysWords += wordsLearned
        totalLearned += wordsLearned
        
        // Update in UserDefaults
        UserDefaultsManager.shared.updateStats(wordsStudiedToday: wordsLearned)
    }
    
    /// Track app launch for streak
    func trackAppLaunch() {
        // TODO: Implement streak logic in Day 8-11
        // - Check if last launch was yesterday -> maintain streak
        // - Check if last launch was today -> do nothing
        // - Otherwise -> reset streak to 1
    }
}
