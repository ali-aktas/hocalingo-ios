//
//  PackageSelectionViewModel.swift
//  HocaLingo
//
//  Created by Auralian on 15.01.2026.
//

import SwiftUI
import Combine

// MARK: - Package Model
struct PackageModel: Identifiable, Codable {
    let id: String
    let level: String
    let name: String
    let description: String
    let wordCount: Int
    let colorHex: String
    
    var color: Color {
        Color.fromHex(colorHex)
    }
}

// MARK: - Package Selection View Model
class PackageSelectionViewModel: ObservableObject {
    
    @Published var packages: [PackageModel] = []
    @Published var selectedPackageId: String? = nil
    @Published var isLoading: Bool = false
    
    init() {
        loadPackages()
    }
    
    private func loadPackages() {
        isLoading = true
        
        packages = [
            PackageModel(
                id: "en_tr_a1_001",
                level: "A1",
                name: "Beginner",
                description: "Basic everyday words",
                wordCount: 500,
                colorHex: "FFB3BA"
            ),
            PackageModel(
                id: "a2_en_tr_v1",
                level: "A2",
                name: "Elementary",
                description: "Common phrases",
                wordCount: 600,
                colorHex: "FFDFBA"
            ),
            PackageModel(
                id: "b1_en_tr_v1",
                level: "B1",
                name: "Intermediate",
                description: "Work and travel",
                wordCount: 800,
                colorHex: "FFFFBA"
            ),
            PackageModel(
                id: "b2_en_tr_v1",
                level: "B2",
                name: "Upper Intermediate",
                description: "Complex topics",
                wordCount: 1000,
                colorHex: "BAFFC9"
            ),
            PackageModel(
                id: "c1_en_tr_v1",
                level: "C1",
                name: "Advanced",
                description: "Academic language",
                wordCount: 1200,
                colorHex: "BAE1FF"
            ),
            PackageModel(
                id: "c2_en_tr_v1",
                level: "C2",
                name: "Mastery",
                description: "Native-like fluency",
                wordCount: 1500,
                colorHex: "D4BAFF"
            )
        ]
        
        isLoading = false
    }
    
    func selectPackage(_ packageId: String) {
        selectedPackageId = packageId
    }
    
    func loadPackageWordCount(_ packageId: String) -> Int {
        packages.first(where: { $0.id == packageId })?.wordCount ?? 0
    }
}

// MARK: - Color Extension
extension Color {
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
