//
//  AddWordDialogView.swift
//  HocaLingo
//
//  Premium, theme-aware manual word entry dialog.
//

import SwiftUI
import Combine

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
                // 1. Dinamik Arka Plan
                Color.themeBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Bilgi Paneli
                        infoBanner
                        
                        // İngilizce Giriş Bölümü
                        wordSection(
                            title: NSLocalizedString("add_word_english", comment: ""),
                            wordText: $viewModel.englishWord,
                            exampleText: $viewModel.exampleEn,
                            examplePlaceholder: NSLocalizedString("add_word_example_en", comment: ""),
                            icon: "textformat.abc",
                            accentColor: .themePrimaryButton,
                            placeholder: "e.g. Serendipity"
                        )
                        
                        // Türkçe Giriş Bölümü
                        wordSection(
                            title: NSLocalizedString("add_word_turkish", comment: ""),
                            wordText: $viewModel.turkishWord,
                            exampleText: $viewModel.exampleTr,
                            examplePlaceholder: NSLocalizedString("add_word_example_tr", comment: ""),
                            icon: "character.book.closed.fill",
                            accentColor: .accentTeal,
                            placeholder: "Örn: Mutlu tesadüf"
                        )
                        
                        Spacer(minLength: 20)
                        
                        // Kaydet Butonu
                        saveButtonSection
                        
                        // Hata Mesajı (Varsa)
                        if let error = viewModel.errorMessage {
                            errorBanner(message: error)
                        }
                    }
                    .padding(20)
                }
                
                // Başarı Overlay (Premium Bulanıklık Efekti)
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
                    .foregroundColor(.themePrimary)
                    .fontWeight(.medium)
                }
            }
            .onChange(of: viewModel.showSuccessAnimation) { _, newValue in
                if newValue {
                    withAnimation(.spring()) {
                        showSuccessAnimation = true
                    }
                    // Animasyon sonrası otomatik kapanış
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - UI Components
private extension AddWordDialogView {
    
    func wordSection(
        title: String,
        wordText: Binding<String>,
        exampleText: Binding<String>,
        examplePlaceholder: String,
        icon: String,
        accentColor: Color,
        placeholder: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(accentColor)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                // Kelime TextField
                TextField(placeholder, text: wordText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .padding()
                    .background(Color.themeCard)
                    .cornerRadius(14, corners: [.topLeft, .topRight])
                    .textInputAutocapitalization(.never)
                
                Divider()
                    .background(Color.themeDivider)
                    .padding(.horizontal)
                
                // Örnek Cümle TextField
                HStack(spacing: 10) {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 12))
                        .foregroundColor(accentColor.opacity(0.6))
                    
                    TextField(examplePlaceholder, text: exampleText)
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                        .textInputAutocapitalization(.sentences)
                }
                .padding()
                .background(Color.themeCard)
                .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.themeBorder, lineWidth: 1)
            )
            .shadow(color: Color.themeShadow, radius: 10, y: 4)
        }
    }
    
    var infoBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundColor(.accentOrange)
            
            Text(NSLocalizedString("add_word_info", comment: ""))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.themeSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.accentOrange.opacity(0.1))
        .cornerRadius(16)
    }
    
    var saveButtonSection: some View {
        Button {
            viewModel.saveWord()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(NSLocalizedString("add_word_save", comment: ""))
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                viewModel.canSave ?
                LinearGradient(colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd], startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(18)
            .shadow(color: viewModel.canSave ? Color.themePrimaryButtonShadow : Color.clear, radius: 12, y: 6)
        }
        .disabled(!viewModel.canSave || viewModel.isLoading)
        .padding(.top, 8)
    }

    func errorBanner(message: String) -> some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
    }
    
    var successOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.accentGreen)
                    .symbolEffect(.bounce, value: showSuccessAnimation)
                
                Text(NSLocalizedString("add_word_success", comment: ""))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.themePrimary)
            }
            .padding(40)
            .background(Color.themeCard)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.2), radius: 40)
        }
    }
}

// MARK: - Helper for Selective Rounded Corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - ViewModel (Logic & IDs Preserved)
class AddWordViewModel: ObservableObject {
    @Published var englishWord: String = ""
    @Published var turkishWord: String = ""
    @Published var exampleEn: String = ""
    @Published var exampleTr: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessAnimation: Bool = false
    
    private let userDefaults = UserDefaultsManager.shared
    
    var canSave: Bool {
        !englishWord.trimmingCharacters(in: .whitespaces).isEmpty &&
        !turkishWord.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func saveWord() {
        guard canSave else { return }
        isLoading = true
        errorMessage = nil
        
        let newWordId = generateUniqueWordId()
        let example = Example(
            en: exampleEn.trimmingCharacters(in: .whitespaces),
            tr: exampleTr.trimmingCharacters(in: .whitespaces)
        )
        
        let newWord = Word(
            id: newWordId,
            english: englishWord.trimmingCharacters(in: .whitespaces),
            turkish: turkishWord.trimmingCharacters(in: .whitespaces),
            example: example,
            pronunciation: "",
            level: "CUSTOM",
            category: "user_added",
            reversible: true,
            userAdded: true
        )
        
        var userWords = userDefaults.loadUserAddedWords()
        userWords.append(newWord)
        userDefaults.saveUserAddedWords(userWords)
        
        createInitialProgress(for: newWord)
        
        isLoading = false
        showSuccessAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.clearForm()
        }
    }
    
    private func generateUniqueWordId() -> Int {
        let existingWords = userDefaults.loadUserAddedWords()
        let maxId = existingWords.map { $0.id }.max() ?? 99999
        return max(100000, maxId + 1)
    }
    
    private func createInitialProgress(for word: Word) {
        let directions: [StudyDirection] = [.enToTr, .trToEn]
        for dir in directions {
            let prog = Progress(
                wordId: word.id, direction: dir, repetitions: 0,
                intervalDays: 0, easeFactor: 2.5, nextReviewAt: Date(),
                lastReviewAt: nil, learningPhase: true, sessionPosition: nil,
                successfulReviews: 0, hardPresses: 0, isSelected: true,
                createdAt: Date(), updatedAt: Date()
            )
            userDefaults.saveProgress(prog, for: word.id, direction: dir)
        }
    }
    
    private func clearForm() {
        englishWord = ""; turkishWord = ""; exampleEn = ""; exampleTr = ""; errorMessage = nil
    }
}
