//
//  PackageSelectionViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Premium packages, modern colors, category system
//  Location: HocaLingo/Features/Selection/PackageSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Package Category
enum PackageCategory: String, Codable {
    case standard
    case premium
}

// MARK: - Package Model
struct PackageModel: Identifiable, Codable {
    let id: String
    let level: String
    let name: String
    let description: String
    let wordCount: Int
    let colorHex: String
    let isPremium: Bool
    let category: PackageCategory
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Package Selection View Model
class PackageSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var standardPackages: [PackageModel] = []
    @Published var premiumPackages: [PackageModel] = []
    @Published var selectedPackageId: String? = nil
    @Published var isLoading: Bool = false
    @Published var showEmptyPackageAlert: Bool = false
    @Published var showPremiumSheet: Bool = false
    @Published var isPremium: Bool = false
    
    // MARK: - Private Properties
    private let jsonLoader = JSONLoader()
    private let userDefaults = UserDefaultsManager.shared
    private let premiumManager = PremiumManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        // Subscribe to premium status
        premiumManager.$isPremium
            .assign(to: &$isPremium)
        
        loadPackages()
    }
    
    // MARK: - Load Packages
    private func loadPackages() {
        isLoading = true
        
        // ✅ STANDARD PACKAGES (Modern Colors - Better Readability)
        let standardMetadata: [(id: String, level: String, name: String, description: String, colorHex: String)] = [
            (
                id: "standard_a1_001",
                level: "level_a1",
                name: "package_name_beginner",
                description: "Basic everyday words",
                colorHex: "FF6B6B" // Vibrant red
            ),
            (
                id: "standard_a2_001",
                level: "level_a2",
                name: "package_name_elementary",
                description: "Common phrases",
                colorHex: "FFA94D" // Warm orange
            ),
            (
                id: "standard_b1_001",
                level: "level_b1",
                name: "package_name_intermediate",
                description: "Work and travel",
                colorHex: "FFD93D" // Bright yellow
            ),
            (
                id: "standard_b2_001",
                level: "level_b2",
                name: "package_name_upper_intermediate",
                description: "Complex topics",
                colorHex: "6BCF7F" // Fresh green
            ),
            (
                id: "standard_c1_001",
                level: "level_c1",
                name: "package_name_advanced",
                description: "Academic language",
                colorHex: "4ECDC4" // Teal
            ),
            (
                id: "standard_c2_001",
                level: "level_c2",
                name: "package_name_mastery",
                description: "Native-like fluency",
                colorHex: "9B59B6" // Purple
            )
        ]
        
        // ✅ PREMIUM PACKAGES (Gold Theme - Thematic)
        let premiumMetadata: [(id: String, level: String, name: String, description: String, colorHex: String)] = [
            (
                id: "premium_business_001",
                level: "premium_level",
                name: "premium_package_business",
                description: "Professional workplace English",
                colorHex: "DAA520" // Goldenrod
            ),
            (
                id: "premium_travel_001",
                level: "premium_level",
                name: "premium_package_travel",
                description: "Tourism and navigation",
                colorHex: "FFD700" // Gold
            ),
            (
                id: "premium_tech_001",
                level: "premium_level",
                name: "premium_package_tech",
                description: "Programming and IT terms",
                colorHex: "F4A460" // Sandy brown
            ),
            (
                id: "premium_medical_001",
                level: "premium_level",
                name: "premium_package_medical",
                description: "Healthcare vocabulary",
                colorHex: "DDA15E" // Bronze
            ),
            (
                id: "premium_academic_001",
                level: "premium_level",
                name: "premium_package_academic",
                description: "University and research",
                colorHex: "CD853F" // Peru
            ),
            (
                id: "premium_idioms_001",
                level: "premium_level",
                name: "premium_package_idioms",
                description: "Native expressions",
                colorHex: "D4AF37" // Gold (metallic)
            )
        ]
        
        // Build standard packages
        standardPackages = standardMetadata.map { metadata in
            let wordCount = loadWordCount(for: metadata.id)
            return PackageModel(
                id: metadata.id,
                level: metadata.level,
                name: metadata.name,
                description: metadata.description,
                wordCount: wordCount,
                colorHex: metadata.colorHex,
                isPremium: false,
                category: .standard
            )
        }
        
        // Build premium packages
        premiumPackages = premiumMetadata.map { metadata in
            let wordCount = loadWordCount(for: metadata.id)
            return PackageModel(
                id: metadata.id,
                level: metadata.level,
                name: metadata.name,
                description: metadata.description,
                wordCount: wordCount,
                colorHex: metadata.colorHex,
                isPremium: true,
                category: .premium
            )
        }
        
        isLoading = false
        print("📦 Loaded \(standardPackages.count) standard + \(premiumPackages.count) premium packages")
    }
    
    // MARK: - Load Word Count
    private func loadWordCount(for packageId: String) -> Int {
        do {
            let vocabPackage = try jsonLoader.loadVocabularyPackage(filename: packageId)
            return vocabPackage.words.count
        } catch {
            print("⚠️ Could not load word count for \(packageId): \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Select Package
    func selectPackage(_ package: PackageModel) {
        // Check premium access
        if package.isPremium && !isPremium {
            showPremiumSheet = true
            print("🔒 Premium package locked: \(package.name)")
            return
        }
        
        selectedPackageId = package.id
        print("✅ Selected package: \(package.id)")
    }
    
    // MARK: - Get All Packages
    var allPackages: [PackageModel] {
        return standardPackages + premiumPackages
    }
    
    // MARK: - Get Package Info
    func getPackage(_ packageId: String) -> PackageModel? {
        return allPackages.first(where: { $0.id == packageId })
    }
    
    // MARK: - Get Total Unseen Words
    func getUnseenWordCount(for packageId: String) -> Int {
        let selections = userDefaults.getWordSelections(packageId: packageId)
        let totalWords = loadWordCount(for: packageId)
        let processedWords = selections.selected.count + selections.hidden.count
        
        return max(0, totalWords - processedWords)
    }
}
