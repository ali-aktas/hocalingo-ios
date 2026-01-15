//
//  JSONLoader.swift
//  HocaLingo
//
//  Core/Storage - JSON file loading utility
//

import Foundation

// MARK: - JSON Loader
/// Utility class for loading vocabulary JSON files from app bundle
class JSONLoader {
    
    /// Load a vocabulary package from JSON file
    /// - Parameter fileName: Name of JSON file (without .json extension)
    /// - Returns: VocabularyPackage or nil if loading fails
    static func loadPackage(fileName: String) -> VocabularyPackage? {
        // Get bundle path
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("❌ JSON file not found: \(fileName).json")
            return nil
        }
        
        do {
            // Read file data
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Decode JSON
            let decoder = JSONDecoder()
            let package = try decoder.decode(VocabularyPackage.self, from: data)
            
            print("✅ Loaded package: \(package.packageInfo.id) with \(package.words.count) words")
            return package
            
        } catch {
            print("❌ JSON parsing error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Load multiple packages at once
    /// - Parameter fileNames: Array of JSON file names
    /// - Returns: Array of successfully loaded packages
    static func loadPackages(fileNames: [String]) -> [VocabularyPackage] {
        return fileNames.compactMap { loadPackage(fileName: $0) }
    }
}
