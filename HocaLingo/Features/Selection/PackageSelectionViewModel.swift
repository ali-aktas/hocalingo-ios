//
//  PackageSelectionViewModel.swift
//  HocaLingo
//
//  🔴 REDESIGN: Added iconName to PackageModel for SF Symbols
//  🔴 REDESIGN: Premium packages updated (Travel, Business, Phrases, Idioms, Social, Academic)
//  ✅ PRESERVED: All logic, functions, premium manager, standard IDs
//  ✅ PRESERVED: loadWordCount, selectPackage, getUnseenWordCount
//
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
    let iconName: String // SF Symbol name
    
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
        premiumManager.$isPremium
            .assign(to: &$isPremium)
        
        loadPackages()
    }
    
    // MARK: - Load Packages
    private func loadPackages() {
        isLoading = true
        
        // STANDARD PACKAGES — Purple monochrome, ~12 brightness units per step
        // A1 (lightest #9B8FD4) → C2 (darkest #594798), clearly distinct but same family
        let standardMetadata: [(id: String, level: String, name: String, description: String, colorHex: String, iconName: String)] = [
            (
                id: "standard_a1_001",
                level: "level_a1",
                name: "package_name_beginner",
                description: "Basic everyday words",
                colorHex: "9B8FD4",   // Lightest purple
                iconName: "leaf.fill"
            ),
            (
                id: "standard_a2_001",
                level: "level_a2",
                name: "package_name_elementary",
                description: "Common phrases",
                colorHex: "8E80C8",   // ~12 units darker
                iconName: "book.fill"
            ),
            (
                id: "standard_b1_001",
                level: "level_b1",
                name: "package_name_intermediate",
                description: "Work and travel vocabulary",
                colorHex: "8172BC",   // ~12 units darker
                iconName: "bookmark.fill"
            ),
            (
                id: "standard_b2_001",
                level: "level_b2",
                name: "package_name_upper_intermediate",
                description: "Professional English",
                colorHex: "7363B0",   // ~12 units darker
                iconName: "text.book.closed.fill"
            ),
            (
                id: "standard_c1_001",
                level: "level_c1",
                name: "package_name_advanced",
                description: "Advanced expressions",
                colorHex: "6655A4",   // ~12 units darker
                iconName: "graduationcap.fill"
            ),
            (
                id: "standard_c2_001",
                level: "level_c2",
                name: "package_name_mastery",
                description: "Near-native vocabulary",
                colorHex: "594798",   // Darkest purple
                iconName: "crown.fill"
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
                category: .standard,
                iconName: metadata.iconName
            )
        }
        
        // PREMIUM PACKAGES — Themed collections with unique gold tones
        let premiumMetadata: [(id: String, level: String, name: String, description: String, colorHex: String, iconName: String)] = [
            (
                id: "premium_travel_001",
                level: "premium_level",
                name: "premium_package_travel",
                description: "Tourism and navigation",
                colorHex: "FFD700",   // Gold
                iconName: "airplane"
            ),
            (
                id: "premium_business_001",
                level: "premium_level",
                name: "premium_package_business",
                description: "Professional workplace English",
                colorHex: "DAA520",   // Goldenrod
                iconName: "briefcase.fill"
            ),
            (
                id: "premium_phrases_001",
                level: "premium_level",
                name: "premium_package_phrases",
                description: "Common native expressions",
                colorHex: "F4A460",   // Sandy brown
                iconName: "text.bubble.fill"
            ),
            (
                id: "premium_idioms_001",
                level: "premium_level",
                name: "premium_package_idioms",
                description: "Native expressions",
                colorHex: "D4AF37",   // Metallic gold
                iconName: "theatermasks.fill"
            ),
            (
                id: "premium_social_001",
                level: "premium_level",
                name: "premium_package_social",
                description: "Daily conversation skills",
                colorHex: "DDA15E",   // Bronze
                iconName: "person.2.fill"
            ),
            (
                id: "premium_academic_001",
                level: "premium_level",
                name: "premium_package_academic",
                description: "University and research",
                colorHex: "CD853F",   // Peru
                iconName: "building.columns.fill"
            )
        ]
        
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
                category: .premium,
                iconName: metadata.iconName
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
    
    // MARK: - Get Unseen Word Count
    func getUnseenWordCount(for packageId: String) -> Int {
        let selections = userDefaults.getWordSelections(packageId: packageId)
        let totalWords = loadWordCount(for: packageId)
        let processedWords = selections.selected.count + selections.hidden.count
        return max(0, totalWords - processedWords)
    }
}
