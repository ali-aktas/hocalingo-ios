//
//  AddWordDialogView.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Premium theme-aware UI from scratch
//  - ProfileView gradient background + ambient glow
//  - FocusState animated border highlights
//  - Sticky save button outside ScrollView (like StoryCreatorSheet)
//  - Clean section headers with rounded icon squares
//  ✅ PRESERVED: All ViewModel logic unchanged
//  Location: Features/Home/AddWordDialogView.swift
//

import SwiftUI
import Combine

// MARK: - Add Word Dialog View
struct AddWordDialogView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    @StateObject private var viewModel = AddWordViewModel()
    @AppStorage("app_language") private var appLanguageCode: String = "en"

    @State private var showSuccessAnimation = false
    @FocusState private var focusedField: FormField?

    private enum FormField { case enWord, enExample, trWord, trExample }

    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // ── Background (matches ProfileView) ──
                LinearGradient(
                    colors: isDarkMode
                        ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                        : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Ambient glow
                Circle()
                    .fill(Color.accentPurple.opacity(isDarkMode ? 0.13 : 0.07))
                    .frame(width: 320, height: 320)
                    .blur(radius: 70)
                    .offset(x: 120, y: -200)
                    .allowsHitTesting(false)

                // ── Main layout: Scroll + sticky button ──
                VStack(spacing: 0) {

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {

                            infoBanner
                                .padding(.top, 4)

                            inputSection(
                                headerKey: "add_word_english",
                                headerIcon: "textformat.abc",
                                accentColor: Color(hex: "6366F1"),
                                wordBinding: $viewModel.englishWord,
                                wordField: .enWord,
                                wordPlaceholder: "e.g. Serendipity",
                                exampleKey: "add_word_example_en",
                                exampleBinding: $viewModel.exampleEn,
                                exampleField: .enExample,
                                nextField: .trWord
                            )

                            inputSection(
                                headerKey: "add_word_turkish",
                                headerIcon: "character.book.closed.fill",
                                accentColor: Color(hex: "4ECDC4"),
                                wordBinding: $viewModel.turkishWord,
                                wordField: .trWord,
                                wordPlaceholder: "Örn: Mutlu tesadüf",
                                exampleKey: "add_word_example_tr",
                                exampleBinding: $viewModel.exampleTr,
                                exampleField: .trExample,
                                nextField: nil
                            )

                            if let error = viewModel.errorMessage {
                                errorBanner(message: error)
                            }

                            Spacer(minLength: 16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    }

                    // ── Sticky bottom button ──
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.themeSecondary.opacity(0.15))

                        saveButton
                            .padding(.horizontal, 20)
                            .padding(.top, 14)
                            .padding(.bottom, 28)
                    }
                    .background(
                        (isDarkMode ? Color(hex: "211A2E") : Color(hex: "FAF1FF"))
                            .opacity(0.97)
                    )
                }

                // ── Success overlay ──
                if showSuccessAnimation {
                    successOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(LocalizedStringKey("add_word_title"))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.themeSecondary)
                    }
                }
            }
            .onChange(of: viewModel.showSuccessAnimation) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                        showSuccessAnimation = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Info Banner
    private var infoBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "FB9322").opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: "sparkles")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "FB9322"))
            }

            Text(LocalizedStringKey("add_word_info"))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.themeSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "FB9322").opacity(isDarkMode ? 0.07 : 0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "FB9322").opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Input Section
    private func inputSection(
        headerKey: String,
        headerIcon: String,
        accentColor: Color,
        wordBinding: Binding<String>,
        wordField: FormField,
        wordPlaceholder: String,
        exampleKey: String,
        exampleBinding: Binding<String>,
        exampleField: FormField,
        nextField: FormField?
    ) -> some View {
        let isActive = focusedField == wordField || focusedField == exampleField

        return VStack(alignment: .leading, spacing: 10) {

            // Section header
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: headerIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                Text(LocalizedStringKey(headerKey))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
                Spacer()
            }

            // Stacked card
            VStack(spacing: 0) {

                // Word field
                TextField(wordPlaceholder, text: wordBinding)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .focused($focusedField, equals: wordField)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(nextField != nil ? .next : .done)
                    .onSubmit { focusedField = exampleField }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                Divider()
                    .background(Color.themeDivider)
                    .padding(.horizontal, 16)

                // Example field
                HStack(spacing: 10) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor.opacity(0.45))
                        .frame(width: 16)

                    TextField(L(exampleKey), text: exampleBinding)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.themeSecondary)
                        .focused($focusedField, equals: exampleField)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(nextField != nil ? .next : .done)
                        .onSubmit {
                            focusedField = nextField
                        }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.themeCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isActive ? accentColor.opacity(0.5) : Color.themeBorder.opacity(0.6),
                        lineWidth: isActive ? 2 : 1
                    )
            )
            .shadow(
                color: isActive
                    ? accentColor.opacity(0.2)
                    : Color.black.opacity(isDarkMode ? 0.18 : 0.05),
                radius: isActive ? 14 : 8,
                x: 0, y: 4
            )
            .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            focusedField = nil
            viewModel.saveWord()
        } label: {
            ZStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 19, weight: .semibold))
                        Text(LocalizedStringKey("add_word_save"))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if viewModel.canSave {
                        LinearGradient(
                            colors: [.themePrimaryButtonGradientStart, .themePrimaryButtonGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(18)
            .shadow(
                color: viewModel.canSave ? Color.themePrimaryButtonShadow.opacity(0.45) : .clear,
                radius: 14, x: 0, y: 6
            )
        }
        .disabled(!viewModel.canSave || viewModel.isLoading)
        .scaleEffect(viewModel.canSave ? 1.0 : 0.97)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.canSave)
    }

    // MARK: - Error Banner
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "4ECDC4").opacity(0.12))
                        .frame(width: 110, height: 110)
                    Circle()
                        .fill(Color(hex: "4ECDC4").opacity(0.2))
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .symbolEffect(.bounce, value: showSuccessAnimation)
                }

                Text(LocalizedStringKey("add_word_success"))
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.themePrimary)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 44)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.themeCard)
                    .shadow(color: .black.opacity(isDarkMode ? 0.4 : 0.15), radius: 50, y: 10)
            )
            .padding(.horizontal, 52)
        }
    }
}

// MARK: - Rounded Corner Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - ViewModel (Logic unchanged)
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
