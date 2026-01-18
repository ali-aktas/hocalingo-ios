//
//  PackageSelectionViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Real word counts from JSON files (Android parity)
//  Location: HocaLingo/Features/Selection/PackageSelectionViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Package Model
struct PackageModel: Identifiable, Codable {
    let id: String
    let level: String
    let name: String
    let description: String
    let wordCount: Int // ✅ Now dynamically loaded from JSON
    let colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Package Selection View Model
class PackageSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var packages: [PackageModel] = []
    @Published var selectedPackageId: String? = nil
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private let jsonLoader = JSONLoader()
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Initialization
    init() {
        loadPackages()
    }
    
    // MARK: - Load Packages
    private func loadPackages() {
        isLoading = true
        
        // Package metadata with JSON filenames
        let packageMetadata: [(id: String, level: String, name: String, description: String, colorHex: String)] = [
            (
                id: "en_tr_a1_001",
                level: "A1",
                name: "Beginner",
                description: "Basic everyday words",
                colorHex: "FFB3BA"
            ),
            (
                id: "en_tr_a2_001",
                level: "A2",
                name: "Elementary",
                description: "Common phrases",
                colorHex: "FFDFBA"
            ),
            (
                id: "en_tr_b1_001",
                level: "B1",
                name: "Intermediate",
                description: "Work and travel",
                colorHex: "FFFFBA"
            ),
            (
                id: "en_tr_b2_001",
                level: "B2",
                name: "Upper Intermediate",
                description: "Complex topics",
                colorHex: "BAFFC9"
            ),
            (
                id: "en_tr_c1_001",
                level: "C1",
                name: "Advanced",
                description: "Academic language",
                colorHex: "BAE1FF"
            ),
            (
                id: "en_tr_c2_001",
                level: "C2",
                name: "Mastery",
                description: "Native-like fluency",
                colorHex: "D4BAFF"
            )
        ]
        
        // Load real word counts from JSON files
        packages = packageMetadata.map { metadata in
            // Try to load word count from JSON
            let wordCount = loadWordCount(for: metadata.id)
            
            print("📦 Package \(metadata.level): \(wordCount) words")
            
            return PackageModel(
                id: metadata.id,
                level: metadata.level,
                name: metadata.name,
                description: metadata.description,
                wordCount: wordCount,
                colorHex: metadata.colorHex
            )
        }
        
        isLoading = false
        print("✅ Loaded \(packages.count) packages with real word counts")
    }
    
    // MARK: - Load Word Count
    /// Load real word count from JSON file
    /// - Parameter packageId: Package ID (JSON filename)
    /// - Returns: Number of words in package (0 if file not found)
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
    func selectPackage(_ packageId: String) {
        selectedPackageId = packageId
        print("✅ Selected package: \(packageId)")
    }
    
    // MARK: - Get Package Info
    func getPackage(_ packageId: String) -> PackageModel? {
        return packages.first(where: { $0.id == packageId })
    }
    
    // MARK: - Get Total Unseen Words
    /// Get number of unseen words in a package
    /// - Parameter packageId: Package ID
    /// - Returns: Number of unseen words
    func getUnseenWordCount(for packageId: String) -> Int {
        let selections = userDefaults.getWordSelections(packageId: packageId)
        let totalWords = loadWordCount(for: packageId)
        let processedWords = selections.selected.count + selections.hidden.count
        
        return max(0, totalWords - processedWords)
    }
}
