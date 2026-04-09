//
//  WordVaultViewModel.swift
//  HocaLingo
//
//  ✅ UPDATED: Multi-meaning support, hardPresses data for quiz
//  Location: Features/Home/WordVault/WordVaultViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Vault Word
struct VaultWord: Identifiable {
    let id: Int
    let english: String
    let turkish: String              // Primary meaning (backward compat)
    let allMeanings: String          // All meanings joined — "ışık, hafif"
    let meanings: [Meaning]          // Full meaning objects with examples
    let addedOrder: Int              // lower = older, higher = newer
    let isUserAdded: Bool
    let hardPresses: Int             // Hard button press count
}

// MARK: - Word Vault View Model
class WordVaultViewModel: ObservableObject {

    @Published private(set) var vaultWords: [VaultWord] = []
    @Published private(set) var isLoading: Bool = false

    // First 5 words shown in the preview row on HomeView
    var previewWords: [VaultWord] { Array(vaultWords.prefix(5)) }
    var totalCount: Int { vaultWords.count }

    /// Words with 3+ hard presses (for hard words quiz)
    var hardWords: [VaultWord] {
        vaultWords.filter { $0.hardPresses >= 3 }
    }
    var hardWordsCount: Int { hardWords.count }

    private let jsonLoader = JSONLoader()
    private let userDefaults = UserDefaultsManager.shared

    // MARK: - Load
    func load() {
        guard !isLoading else { return }
        isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let words = self.buildVaultWords()
            DispatchQueue.main.async {
                self.vaultWords = words
                self.isLoading = false
            }
        }
    }

    func reload() {
        vaultWords = []
        load()
    }

    // MARK: - Private
    private func buildVaultWords() -> [VaultWord] {
        var result: [VaultWord] = []
        var seenIds = Set<Int>()
        var orderCounter = 0

        let direction = userDefaults.loadStudyDirection()

        // Collect from all package selection keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("package_") && $0.hasSuffix("_selected") }
            .sorted()

        for key in allKeys {
            let packageId = String(key.dropFirst("package_".count).dropLast("_selected".count))
            guard let vocabPackage = try? jsonLoader.loadVocabularyPackage(filename: packageId) else { continue }
            let selectedIds = UserDefaults.standard.array(forKey: key) as? [Int] ?? []

            for wordId in selectedIds {
                guard !seenIds.contains(wordId),
                      let word = vocabPackage.words.first(where: { $0.id == wordId }) else { continue }
                seenIds.insert(wordId)

                let progress = userDefaults.loadProgress(for: wordId, direction: direction)
                let hp = progress?.hardPresses ?? 0

                result.append(VaultWord(
                    id: word.id,
                    english: word.english,
                    turkish: word.turkish,
                    allMeanings: word.allTurkishMeanings,
                    meanings: word.meanings,
                    addedOrder: orderCounter,
                    isUserAdded: false,
                    hardPresses: hp
                ))
                orderCounter += 1
            }
        }

        // User-added custom words
        for word in userDefaults.loadUserAddedWords() where !seenIds.contains(word.id) {
            seenIds.insert(word.id)

            let progress = userDefaults.loadProgress(for: word.id, direction: direction)
            let hp = progress?.hardPresses ?? 0

            result.append(VaultWord(
                id: word.id,
                english: word.english,
                turkish: word.turkish,
                allMeanings: word.allTurkishMeanings,
                meanings: word.meanings,
                addedOrder: orderCounter,
                isUserAdded: true,
                hardPresses: hp
            ))
            orderCounter += 1
        }

        // Newest first
        return result.sorted { $0.addedOrder > $1.addedOrder }
    }
}
