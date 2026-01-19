//
//  AddWordDialogView.swift
//  HocaLingo
//
//  ✅ FIXED: All compilation errors resolved
//  - Added import Combine
//  - Fixed Word model (uses Example struct)
//  - Fixed Progress model (intervalDays, nextReviewAt)
//  - Theme-aware UI
//  - Full localization
//
//  Location: HocaLingo/Features/Home/AddWordDialogView.swift
//

import SwiftUI
import Combine  // ✅ FIXED: Added Combine import

// MARK: - Add Word Dialog View
struct AddWordDialogView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @StateObject private var viewModel = AddWordViewModel()
    @State private var showSuccessAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Info Banner
                        infoBanner
                        
                        // Form Fields
                        formFields
                        
                        // Save Button
                        saveButton
                        
                        // Error Display
                        if let error = viewModel.errorMessage {
                            errorBanner(message: error)
                        }
                        
                    }
                    .padding(20)
                }
                
                // Success Animation Overlay
                if showSuccessAnimation {
                    successOverlay
                }
            }
            .navigationTitle(NSLocalizedString("add_word_title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.showSuccessAnimation) { _, newValue in
                if newValue {
                    showSuccessAnimation = true
                    // Auto-dismiss after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Info Banner
private extension AddWordDialogView {
    var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "4ECDC4"))
            
            Text(NSLocalizedString("add_word_info", comment: ""))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "4ECDC4").opacity(0.1))
        )
    }
}

// MARK: - Form Fields
private extension AddWordDialogView {
    var formFields: some View {
        VStack(spacing: 20) {
            
            // English Word (Required)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("add_word_english", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("*")
                        .foregroundColor(.red)
                }
                
                TextField(NSLocalizedString("add_word_english", comment: ""), text: $viewModel.englishWord)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            // Turkish Word (Required)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(NSLocalizedString("add_word_turkish", comment: ""))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    Text("*")
                        .foregroundColor(.red)
                }
                
                TextField(NSLocalizedString("add_word_turkish", comment: ""), text: $viewModel.turkishWord)
                    .textFieldStyle(.roundedBorder)
            }
            
            // English Example (Optional)
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("add_word_example_en", comment: ""))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("Example: I love learning new words", text: $viewModel.exampleEn)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
            }
            
            // Turkish Example (Optional)
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("add_word_example_tr", comment: ""))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("Örnek: Yeni kelimeler öğrenmeyi seviyorum", text: $viewModel.exampleTr)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.sentences)
            }
        }
    }
}

// MARK: - Save Button
private extension AddWordDialogView {
    var saveButton: some View {
        Button {
            viewModel.saveWord()
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(NSLocalizedString("add_word_save", comment: ""))
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                saveButtonGradient
            )
            .cornerRadius(12)
            .opacity(viewModel.canSave ? 1.0 : 0.6)
        }
        .disabled(!viewModel.canSave || viewModel.isLoading)
    }
    
    var saveButtonGradient: LinearGradient {
        let isDark = themeViewModel.isDarkMode(in: colorScheme)
        if isDark {
            // Dark mode: Purple
            return LinearGradient(
                colors: [Color(hex: "9333EA"), Color(hex: "7C3AED")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            // Light mode: Orange
            return LinearGradient(
                colors: [Color(hex: "FB9322"), Color(hex: "FF6B00")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

// MARK: - Error Banner
private extension AddWordDialogView {
    func errorBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.red)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
    }
}

// MARK: - Success Overlay
private extension AddWordDialogView {
    var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text(NSLocalizedString("add_word_success", comment: ""))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 20)
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSuccessAnimation)
    }
}

// MARK: - Add Word View Model
class AddWordViewModel: ObservableObject {
    
    @Published var englishWord: String = ""
    @Published var turkishWord: String = ""
    @Published var exampleEn: String = ""
    @Published var exampleTr: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessAnimation: Bool = false
    
    private let userDefaults = UserDefaultsManager.shared
    
    // MARK: - Computed Properties
    
    var canSave: Bool {
        !englishWord.trimmingCharacters(in: .whitespaces).isEmpty &&
        !turkishWord.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Save Word
    
    func saveWord() {
        guard canSave else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Generate unique ID (starting from 100000 to avoid conflicts with package words)
        let newWordId = generateUniqueWordId()
        
        // ✅ FIXED: Create Word with correct Example struct
        let example = Example(
            en: exampleEn.isEmpty ? "" : exampleEn.trimmingCharacters(in: .whitespaces),
            tr: exampleTr.isEmpty ? "" : exampleTr.trimmingCharacters(in: .whitespaces)
        )
        
        let newWord = Word(
            id: newWordId,
            english: englishWord.trimmingCharacters(in: .whitespaces),
            turkish: turkishWord.trimmingCharacters(in: .whitespaces),
            example: example,  // ✅ FIXED: Use Example struct
            pronunciation: "",  // ✅ FIXED: Empty string, not nil
            level: "CUSTOM",
            category: "user_added",
            reversible: true,
            userAdded: true
        )
        
        // Save word
        var userWords = userDefaults.loadUserAddedWords()
        userWords.append(newWord)
        userDefaults.saveUserAddedWords(userWords)
        
        // Auto-select for study (create progress for both directions)
        createInitialProgress(for: newWord)
        
        // Success
        isLoading = false
        showSuccessAnimation = true
        
        // Clear form after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.clearForm()
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateUniqueWordId() -> Int {
        let existingWords = userDefaults.loadUserAddedWords()
        let maxId = existingWords.map { $0.id }.max() ?? 99999
        return max(100000, maxId + 1)
    }
    
    private func createInitialProgress(for word: Word) {
        // ✅ FIXED: Use correct Progress initializer
        // EN → TR progress
        let progressEnToTr = Progress(
            wordId: word.id,
            direction: .enToTr,
            repetitions: 0,
            intervalDays: 0,  // ✅ FIXED: intervalDays not interval
            easeFactor: 2.5,
            nextReviewAt: Date(),  // ✅ FIXED: nextReviewAt not nextReviewDate
            lastReviewAt: nil,
            learningPhase: true,
            sessionPosition: nil,
            successfulReviews: 0,
            hardPresses: 0,
            isSelected: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        userDefaults.saveProgress(progressEnToTr, for: word.id, direction: .enToTr)
        
        // TR → EN progress
        let progressTrToEn = Progress(
            wordId: word.id,
            direction: .trToEn,
            repetitions: 0,
            intervalDays: 0,  // ✅ FIXED: intervalDays not interval
            easeFactor: 2.5,
            nextReviewAt: Date(),  // ✅ FIXED: nextReviewAt not nextReviewDate
            lastReviewAt: nil,
            learningPhase: true,
            sessionPosition: nil,
            successfulReviews: 0,
            hardPresses: 0,
            isSelected: true,
            createdAt: Date(),
            updatedAt: Date()
        )
        userDefaults.saveProgress(progressTrToEn, for: word.id, direction: .trToEn)
    }
    
    private func clearForm() {
        englishWord = ""
        turkishWord = ""
        exampleEn = ""
        exampleTr = ""
        errorMessage = nil
    }
}

// MARK: - Preview
#Preview {
    AddWordDialogView()
        .environment(\.themeViewModel, ThemeViewModel.shared)
}
