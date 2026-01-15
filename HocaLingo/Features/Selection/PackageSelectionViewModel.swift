//
//  PackageSelectionViewModel.swift
//  HocaLingo
//
//  Created by Auralian on 15.01.2026.
//

import SwiftUI
import Combine

// MARK: - Package Model
/// Represents a vocabulary package (A1-C2)
/// Location: HocaLingo/Features/Selection/PackageSelectionViewModel.swift
struct PackageModel: Identifiable, Codable {
    let id: String
    let level: String
    let name: String
    let description: String
    let wordCount: Int
    let colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Package Selection View Model
/// Business logic for package selection
class PackageSelectionViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var packages: [PackageModel] = []
    @Published var selectedPackageId: String? = nil
    @Published var isLoading: Bool = false
    
    // MARK: - Initialization
    init() {
        loadPackages()
    }
    
    // MARK: - Load Packages
    private func loadPackages() {
        isLoading = true
        
        // Create default packages (same as Android)
        packages = [
            PackageModel(
                id: "en_tr_a1_001",
                level: "A1",
                name: "Beginner",
                description: "Basic everyday words",
                wordCount: 500,
                colorHex: "FFB3BA" // Light pink
            ),
            PackageModel(
                id: "a2_en_tr_v1",
                level: "A2",
                name: "Elementary",
                description: "Common phrases",
                wordCount: 600,
                colorHex: "FFDFBA" // Light orange
            ),
            PackageModel(
                id: "b1_en_tr_v1",
                level: "B1",
                name: "Intermediate",
                description: "Work and travel",
                wordCount: 800,
                colorHex: "FFFFBA" // Light yellow
            ),
            PackageModel(
                id: "b2_en_tr_v1",
                level: "B2",
                name: "Upper Intermediate",
                description: "Complex topics",
                wordCount: 1000,
                colorHex: "BAFFC9" // Light green
            ),
            PackageModel(
                id: "c1_en_tr_v1",
                level: "C1",
                name: "Advanced",
                description: "Academic language",
                wordCount: 1200,
                colorHex: "BAE1FF" // Light blue
            ),
            PackageModel(
                id: "c2_en_tr_v1",
                level: "C2",
                name: "Mastery",
                description: "Native-like fluency",
                wordCount: 1500,
                colorHex: "D4BAFF" // Light purple
            )
        ]
        
        isLoading = false
    }
    
    // MARK: - Actions
    func selectPackage(_ packageId: String) {
        selectedPackageId = packageId
        print("Selected package: \(packageId)")
        
        // TODO: Load actual word count from JSON
        // TODO: Navigate to word selection
    }
    
    func loadPackageWordCount(_ packageId: String) -> Int {
        // TODO: Load from JSON using JSONLoader
        // For now, return fake data
        return packages.first(where: { $0.id == packageId })?.wordCount ?? 0
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
