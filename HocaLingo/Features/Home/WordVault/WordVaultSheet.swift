//
//  WordVaultSheet.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Multi-meaning review cards, hard words button, premium gate
//  Location: Features/Home/WordVault/WordVaultSheet.swift
//

import SwiftUI

// MARK: - Word Vault Sheet
struct WordVaultSheet: View {

    @ObservedObject var vaultVM: WordVaultViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    @State private var flippedWordId: Int? = nil
    @State private var showReview = false
    @State private var showHardReview = false
    @State private var showPremiumPaywall = false

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private var accent: Color { Color(hex: "4ECDC4") }
    private var premiumGold: Color { Color(hex: "FFD700") }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                        : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                if vaultVM.isLoading {
                    ProgressView().scaleEffect(1.5)
                } else if vaultVM.vaultWords.isEmpty {
                    emptyState
                } else {
                    wordList
                }
            }
            .navigationTitle(LocalizedStringKey("vault_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(vaultVM.totalCount)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accent.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .fullScreenCover(isPresented: $showReview) {
                SequentialReviewView(
                    words: vaultVM.vaultWords,
                    accent: accent,
                    titleKey: "vault_review_title"
                )
            }
            .fullScreenCover(isPresented: $showHardReview) {
                HardWordsQuizView()
            }
            .sheet(isPresented: $showPremiumPaywall) {
                PremiumPaywallView()
            }
        }
        .onAppear { vaultVM.load() }
    }

    // MARK: - Word List
    private var wordList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                // Action buttons section
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                ForEach(vaultVM.vaultWords) { word in
                    VaultWordRow(
                        word: word,
                        isFlipped: flippedWordId == word.id,
                        isDark: isDark,
                        accent: accent,
                        onTap: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                flippedWordId = (flippedWordId == word.id) ? nil : word.id
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Action Buttons (Review + Hard Words)
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Review All
            Button(action: { showReview = true }) {
                VStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text(LocalizedStringKey("vault_review_all"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text("\(vaultVM.totalCount)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: accent.opacity(0.3), radius: 10, y: 4)
            }

            // Hard Words (Premium)
            Button(action: { handleHardWordsTap() }) {
                VStack(spacing: 8) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20, weight: .bold))
                        if !PremiumManager.shared.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isDark ? premiumGold : Color(hex: "8B5CF6"))
                                .offset(x: 8, y: -4)
                        }
                    }
                    Text(LocalizedStringKey("vault_hard_words"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Text("\(vaultVM.hardWordsCount)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .foregroundColor(isDark ? premiumGold : Color(hex: "8B5CF6"))
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(isDark
                              ? Color(hex: "2A2235")
                              : Color(hex: "F3EEFF"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            isDark ? premiumGold.opacity(0.25) : Color(hex: "8B5CF6").opacity(0.2),
                            lineWidth: 1.5
                        )
                )
            }
        }
    }

    private func handleHardWordsTap() {
        if !PremiumManager.shared.isPremium {
            showPremiumPaywall = true
        } else if vaultVM.hardWordsCount > 0 {
            showHardReview = true
        }
        // If premium but 0 hard words — button shows 0, nothing happens
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text(LocalizedStringKey("vault_empty_title"))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(LocalizedStringKey("vault_empty_subtitle"))
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
        }
    }
}


// MARK: - Vault Word Row
struct VaultWordRow: View {
    let word: VaultWord
    let isFlipped: Bool
    let isDark: Bool
    let accent: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Circle()
                    .fill(word.isUserAdded ? Color(hex: "FFA726") : accent)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 3) {
                    Text(word.english)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    if isFlipped {
                        Text(word.allMeanings)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(accent)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        Text("• • •")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary.opacity(0.4))
                            .transition(.opacity)
                    }
                }

                Spacer()

                // Hard presses indicator
                if word.hardPresses >= 3 {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "EF4444"))
                        .padding(5)
                        .background(Color(hex: "EF4444").opacity(0.12))
                        .clipShape(Circle())
                }

                if word.isUserAdded {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "FFA726"))
                        .padding(6)
                        .background(Color(hex: "FFA726").opacity(0.15))
                        .clipShape(Circle())
                }

                Image(systemName: isFlipped ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.8))
                    .shadow(color: .black.opacity(isDark ? 0.2 : 0.06), radius: 6, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.25), value: isFlipped)
    }
}


// MARK: - Sequential Review View
struct SequentialReviewView: View {
    let words: [VaultWord]
    let accent: Color
    let titleKey: String

    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var flipDegrees: Double = 0
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }

    private var currentWord: VaultWord {
        guard currentIndex < words.count else {
            return words.last ?? VaultWord(
                id: 0, english: "", turkish: "", allMeanings: "",
                meanings: [], addedOrder: 0, isUserAdded: false, hardPresses: 0
            )
        }
        return words[currentIndex]
    }

    var body: some View {
        ZStack {
            // Theme-aware background
            LinearGradient(
                colors: isDark
                    ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                    : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: title + close
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(LocalizedStringKey(titleKey))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("\(currentIndex + 1) / \(words.count)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accent)
                            .frame(
                                width: geo.size.width * (Double(currentIndex + 1) / Double(max(words.count, 1))),
                                height: 4
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 28)
                .padding(.top, 16)

                Spacer()

                // Flip card
                ZStack {
                    // Back: Turkish meanings + examples
                    reviewBackFace
                        .opacity(isFlipped ? 1 : 0)
                        .rotation3DEffect(.degrees(flipDegrees - 180), axis: (x: 0, y: 1, z: 0))

                    // Front: English
                    reviewFrontFace
                        .opacity(isFlipped ? 0 : 1)
                        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
                }
                .frame(height: 300)
                .padding(.horizontal, 28)
                .onTapGesture { if !isFlipped { flipCard() } }

                Spacer()

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 28)
                    .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Front Face (English)
    private var reviewFrontFace: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(
                LinearGradient(
                    colors: isDark
                        ? [Color(hex: "5C6BC0"), Color(hex: "3949AB")]
                        : [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack(spacing: 12) {
                    Text(currentWord.english)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    if !isFlipped {
                        Text(LocalizedStringKey("vault_tap_to_reveal"))
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 8)
                    }
                }
                .padding(24)
            )
            .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 12, y: 6)
    }

    // MARK: - Back Face (Turkish meanings + examples)
        private var reviewBackFace: some View {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: isDark
                            ? [accent.opacity(0.85), accent.opacity(0.55)]
                            : [accent.opacity(0.9), accent.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()

                        // All meanings with examples
                        ForEach(Array(currentWord.meanings.enumerated()), id: \.offset) { index, meaning in
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 80, height: 1)
                                    .padding(.vertical, 14)
                            }

                            VStack(spacing: 6) {
                                Text(meaning.turkish)
                                    .font(.system(
                                        size: index == 0 ? 28 : 22,
                                        weight: index == 0 ? .bold : .medium,
                                        design: .rounded
                                    ))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                if !meaning.example.en.isEmpty {
                                    Text(meaning.example.en)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.6))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .padding(.top, 2)
                                }
                                if !meaning.example.tr.isEmpty {
                                    Text(meaning.example.tr)
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                )
                .shadow(color: accent.opacity(0.3), radius: 12, y: 6)
        }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentIndex > 0 {
                Button(action: previousWord) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 54, height: 54)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Circle())
                }
            }

            if !isFlipped {
                Button(action: flipCard) {
                    Text(LocalizedStringKey("vault_reveal"))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: accent.opacity(0.3), radius: 8, y: 3)
                }
            } else {
                Button(action: nextWord) {
                    HStack(spacing: 8) {
                        Text(currentIndex < words.count - 1
                             ? LocalizedStringKey("vault_next")
                             : LocalizedStringKey("vault_finish"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: currentIndex < words.count - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "66BB6A"), Color(hex: "43A047")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "66BB6A").opacity(0.3), radius: 8, y: 3)
                }
            }
        }
    }

    // MARK: - Actions
    private func flipCard() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            flipDegrees = 180
            isFlipped = true
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func nextWord() {
        if currentIndex < words.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentIndex += 1
                flipDegrees = 0
                isFlipped = false
            }
        } else {
            dismiss()
        }
    }

    private func previousWord() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex -= 1
            flipDegrees = 0
            isFlipped = false
        }
    }
}
