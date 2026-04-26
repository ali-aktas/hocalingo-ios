//
//  SequentialReviewView.swift
//  HocaLingo
//
//  ✅ V2: Front hint removed — word centered alone (modern minimal UI)
//  ✅ V2: ScrollView replaced with centered VStack — symmetric layout
//         • 1 meaning  → perfectly centered
//         • 2 meanings → symmetric vertical distribution with divider
//         • 3+ meanings (rare) → still centered, slight font scale-down
//  Flip-card sequential review used by the vault "Review All" action.
//  Location: Features/Home/WordVault/SequentialReviewView.swift
//

import SwiftUI

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

                    // Front: English word
                    reviewFrontFace
                        .opacity(isFlipped ? 0 : 1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .padding(.horizontal, 28)
                .rotation3DEffect(
                    .degrees(flipDegrees),
                    axis: (x: 0, y: 1, z: 0)
                )
                .onTapGesture { flipCard() }

                Spacer()

                // Navigation buttons
                navigationButtons
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Front Face (English) — Word centered, no hint clutter
    private var reviewFrontFace: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                LinearGradient(
                    colors: [accent, accent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Single VStack with Spacers above/below for true vertical centering
                VStack {
                    Spacer()
                    
                    Text(currentWord.english)
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                }
            )
            .shadow(color: accent.opacity(0.3), radius: 16, y: 8)
    }

    // MARK: - Back Face (Turkish + examples) — Centered, symmetric per meaning count
    private var reviewBackFace: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Outer VStack with Spacers for vertical centering of the whole content block
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Inner: meanings + examples, balanced spacing based on count
                    VStack(spacing: meaningSpacing) {
                        ForEach(Array(currentWord.meanings.enumerated()), id: \.offset) { index, meaning in
                            // Each meaning block: turkish + (optional) examples
                            VStack(spacing: 6) {
                                Text(meaning.turkish)
                                    .font(.system(
                                        size: turkishFontSize(for: index),
                                        weight: .bold,
                                        design: .rounded
                                    ))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.75)
                                    .lineLimit(2)

                                if !meaning.example.en.isEmpty {
                                    Text(meaning.example.en)
                                        .font(.system(size: exampleFontSize, weight: .regular, design: .rounded))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                if !meaning.example.tr.isEmpty {
                                    Text(meaning.example.tr)
                                        .font(.system(size: exampleFontSize, weight: .regular, design: .rounded))
                                        .italic()
                                        .foregroundColor(.white.opacity(0.5))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                            }
                            
                            // Subtle divider between meanings (only between, not after the last)
                            if index < currentWord.meanings.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.18))
                                    .frame(width: 60, height: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            )
            .shadow(color: accent.opacity(0.3), radius: 12, y: 6)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    // MARK: - Layout Helpers (adaptive sizing based on meaning count)
    
    /// Spacing between meaning blocks — wider for fewer meanings (more breathing room)
    private var meaningSpacing: CGFloat {
        switch currentWord.meanings.count {
        case 1:    return 0          // Single meaning has no siblings
        case 2:    return 22         // Two meanings: comfortable gap
        default:   return 16         // 3+: tighter to fit
        }
    }
    
    /// Turkish word font size — slightly smaller for non-primary meanings
    private func turkishFontSize(for index: Int) -> CGFloat {
        switch currentWord.meanings.count {
        case 1:
            return 32                 // Single meaning: large & bold focus
        case 2:
            return 26                 // Two meanings: balanced (both prominent)
        default:
            return index == 0 ? 24 : 20  // 3+: primary slightly bigger
        }
    }
    
    /// Example sentence font size — fixed across counts for consistency
    private var exampleFontSize: CGFloat { 13 }

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
                             : LocalizedStringKey("vault_done"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: currentIndex < words.count - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "6366F1"), Color(hex: "4F46E5")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "6366F1").opacity(0.3), radius: 8, y: 3)
                }
            }
        }
    }

    // MARK: - Actions
    private func flipCard() {
        SoundManager.shared.playCardFlip()
        withAnimation(.easeInOut(duration: 0.6)) {
            flipDegrees += 180
            isFlipped.toggle()
        }
    }

    private func previousWord() {
        guard currentIndex > 0 else { return }
        SoundManager.shared.playClickSound()
        
        // Reset flip state before moving
        if isFlipped {
            withAnimation(.easeInOut(duration: 0.3)) {
                flipDegrees = 0
                isFlipped = false
            }
        }
        
        withAnimation(.spring(response: 0.4)) {
            currentIndex -= 1
        }
    }

    private func nextWord() {
        SoundManager.shared.playClickSound()
        
        if currentIndex >= words.count - 1 {
            // Done — dismiss view
            dismiss()
            return
        }
        
        // Reset flip state before moving
        withAnimation(.easeInOut(duration: 0.3)) {
            flipDegrees = 0
            isFlipped = false
        }
        
        withAnimation(.spring(response: 0.4)) {
            currentIndex += 1
        }
    }
}
