//
//  WordVaultViewModel.swift
//  HocaLingo
//
//  Location: Features/Home/WordVault/WordVaultViewModel.swift
//

import SwiftUI
import Combine

// MARK: - Vault Word
struct VaultWord: Identifiable {
    let id: Int
    let english: String
    let turkish: String
    let addedOrder: Int      // lower = older, higher = newer
    let isUserAdded: Bool
}

// MARK: - Word Vault View Model
class WordVaultViewModel: ObservableObject {

    @Published private(set) var vaultWords: [VaultWord] = []
    @Published private(set) var isLoading: Bool = false

    // First 5 words shown in the preview row on HomeView
    var previewWords: [VaultWord] { Array(vaultWords.prefix(5)) }
    var totalCount: Int { vaultWords.count }

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

        // Collect from all package selection keys
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.hasPrefix("package_") && $0.hasSuffix("_selected") }
            .sorted()   // deterministic order

        for key in allKeys {
            let packageId = String(key.dropFirst("package_".count).dropLast("_selected".count))
            guard let vocabPackage = try? jsonLoader.loadVocabularyPackage(filename: packageId) else { continue }
            let selectedIds = UserDefaults.standard.array(forKey: key) as? [Int] ?? []

            for wordId in selectedIds {
                guard !seenIds.contains(wordId),
                      let word = vocabPackage.words.first(where: { $0.id == wordId }) else { continue }
                seenIds.insert(wordId)
                result.append(VaultWord(
                    id: word.id,
                    english: word.english,
                    turkish: word.turkish,
                    addedOrder: orderCounter,
                    isUserAdded: false
                ))
                orderCounter += 1
            }
        }

        // User-added custom words
        for word in userDefaults.loadUserAddedWords() where !seenIds.contains(word.id) {
            seenIds.insert(word.id)
            result.append(VaultWord(
                id: word.id,
                english: word.english,
                turkish: word.turkish,
                addedOrder: orderCounter,
                isUserAdded: true
            ))
            orderCounter += 1
        }

        // Newest first (highest addedOrder = most recently added via latest package)
        return result.sorted { $0.addedOrder > $1.addedOrder }
    }
}
