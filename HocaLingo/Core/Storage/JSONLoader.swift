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
    
    // MARK: - Static Method (for simple usage)
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
    
    // MARK: - Instance Method (for ViewModel usage)
    /// Load a vocabulary package from JSON file (throws error)
    /// - Parameter filename: Name of JSON file (without .json extension)
    /// - Returns: VocabularyPackage
    /// - Throws: Error if file not found or parsing fails
    func loadVocabularyPackage(filename: String) throws -> VocabularyPackage {
        // Get bundle path
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            throw JSONLoaderError.fileNotFound(filename)
        }
        
        // Read file data
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        
        // Decode JSON
        let decoder = JSONDecoder()
        let package = try decoder.decode(VocabularyPackage.self, from: data)
        
        print("✅ Loaded package: \(package.packageInfo.id) with \(package.words.count) words")
        return package
    }
    
    // MARK: - Multiple Packages
    /// Load multiple packages at once
    /// - Parameter fileNames: Array of JSON file names
    /// - Returns: Array of successfully loaded packages
    static func loadPackages(fileNames: [String]) -> [VocabularyPackage] {
        return fileNames.compactMap { loadPackage(fileName: $0) }
    }
}

// MARK: - JSON Loader Error
enum JSONLoaderError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file not found: \(filename).json"
        case .decodingFailed(let message):
            return "JSON decoding failed: \(message)"
        }
    }
}
