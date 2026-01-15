import SwiftUI
import Combine

// MARK: - Home View Model
/// Business logic for HomeView
/// Location: HocaLingo/Features/Home/HomeViewModel.swift
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var greetingText: String = ""
    @Published var motivationText: String = ""
    @Published var streakDays: Int = 0
    @Published var todaysWords: Int = 0
    @Published var totalLearned: Int = 0
    
    // Motivation texts (rotate daily)
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
        
        // Load user stats (fake data for now)
        loadUserStats()
    }
    
    private func loadUserStats() {
        // TODO: Replace with real data from UserDefaults/CoreData
        // For now, using fake data for testing
        
        streakDays = 7
        todaysWords = 15
        totalLearned = 234
    }
    
    // MARK: - Greeting Generation
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
    
    // MARK: - Actions
    func startStudy() {
        // TODO: Navigate to study screen
        // Check if there are cards to study
        
        let cardsAvailable = todaysWords > 0
        
        if cardsAvailable {
            print("Starting study session...")
            // Navigation will be handled by parent view
        } else {
            print("No cards available. Navigate to package selection.")
            // Show alert or navigate to package selection
        }
    }
    
    func refreshData() {
        loadDashboardData()
    }
    
    // MARK: - Public Methods for Data Updates
    /// Call this when user completes a study session
    func updateAfterStudy(wordsLearned: Int) {
        todaysWords += wordsLearned
        totalLearned += wordsLearned
        
        // TODO: Persist to UserDefaults/CoreData
    }
    
    /// Call this when app launches (for streak tracking)
    func trackAppLaunch() {
        // TODO: Implement streak logic
        // - Check if last launch was yesterday -> maintain streak
        // - Check if last launch was today -> do nothing
        // - Otherwise -> reset streak to 1
    }
}
