//
//  WordVaultSheet.swift
//  HocaLingo
//
//  "Kelime Kasam" full-screen sheet with quick-review.
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

    // FIX: sheet(item:) attached to the Button directly caused a Binding
    // re-creation loop on every render, resulting in the open/close animation
    // cycling endlessly. Using a simple Bool @State + fullScreenCover on the
    // top-level NavigationStack avoids the issue entirely.
    @State private var showReview = false

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private var accent: Color { Color(hex: "4ECDC4") }

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
            // FIX: sheet is declared once at view level, driven by Bool state
            .fullScreenCover(isPresented: $showReview) {
                SequentialReviewView(
                    words: vaultVM.vaultWords,
                    accent: accent
                )
            }
        }
        .onAppear { vaultVM.load() }
    }

    // MARK: - Word List
    private var wordList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                // Review all button — action sets Bool, no sheet attached here
                reviewAllButton
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

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

    // MARK: - Review All Button
    private var reviewAllButton: some View {
        Button(action: { showReview = true }) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(LocalizedStringKey("vault_review_all"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Text("\(vaultVM.totalCount)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [accent, accent.opacity(0.75)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: accent.opacity(0.35), radius: 10, y: 4)
        }
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
                        Text(word.turkish)
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

    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    @State private var flipDegrees: Double = 0
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(hex: "1A1625").ignoresSafeArea()

            VStack(spacing: 28) {
                // Top bar
                HStack {
                    Text("\(currentIndex + 1) / \(words.count)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(accent)
                            .frame(
                                width: geo.size.width * (Double(currentIndex + 1) / Double(words.count)),
                                height: 4
                            )
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 28)

                Spacer()

                // Flip card
                ZStack {
                    // Back: Turkish
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [accent.opacity(0.85), accent.opacity(0.55)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 12) {
                                Text(words[currentIndex].turkish)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                        )
                        .opacity(isFlipped ? 1 : 0)
                        .rotation3DEffect(.degrees(flipDegrees - 180), axis: (x: 0, y: 1, z: 0))

                    // Front: English
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "5C6BC0"), Color(hex: "3949AB")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 12) {
                                Text(words[currentIndex].english)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                if !isFlipped {
                                    Text(NSLocalizedString("vault_tap_to_reveal", comment: ""))
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.top, 8)
                                }
                            }
                            .padding()
                        )
                        .opacity(isFlipped ? 0 : 1)
                        .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
                }
                .frame(height: 280)
                .padding(.horizontal, 28)
                .onTapGesture { if !isFlipped { flipCard() } }

                Spacer()

                // Navigation
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button(action: previousWord) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 54, height: 54)
                                .background(Color.white.opacity(0.1))
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
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 36)
            }
        }
    }

    private func flipCard() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            flipDegrees = 180
            isFlipped   = true
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func nextWord() {
        if currentIndex < words.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentIndex += 1
                flipDegrees  = 0
                isFlipped    = false
            }
        } else {
            dismiss()
        }
    }

    private func previousWord() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex -= 1
            flipDegrees  = 0
            isFlipped    = false
        }
    }
}
