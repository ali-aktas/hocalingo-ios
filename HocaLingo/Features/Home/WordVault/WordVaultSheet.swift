//
//  WordVaultSheet.swift
//  HocaLingo
//
//  ✅ V2: Free-tier quiz access (3 lifetime sessions) + remaining counter on flame button
//  ✅ V2: Paywall triggered ONLY when free limit exhausted; otherwise feature is open
//  Multi-meaning review cards + hard words button + premium gate
//  Location: Features/Home/WordVault/WordVaultSheet.swift
//

import SwiftUI

// MARK: - Word Vault Sheet
struct WordVaultSheet: View {

    @ObservedObject var vaultVM: WordVaultViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    // ✅ V2: Observe limit manager so the "X left" chip stays reactive.
    @ObservedObject private var limitManager = HardWordsQuizLimitManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared

    @State private var flippedWordId: Int? = nil
    @State private var showReview = false
    @State private var showHardReview = false
    @State private var showPremiumPaywall = false

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private var accent: Color { Color(hex: "4ECDC4") }
    private var premiumGold: Color { Color(hex: "FFD700") }
    private var flameOrange: Color { Color(hex: "F97316") }
    private var flameRed: Color { Color(hex: "EF4444") }

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
            Button(action: {
                SoundManager.shared.playClickSound()
                showReview = true
            }) {
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

            // Hard Words — access depends on premium status + lifetime free sessions
            Button(action: { handleHardWordsTap() }) {
                VStack(spacing: 8) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 20, weight: .bold))
                        // Show lock ONLY when the free trial has been fully consumed
                        if limitManager.isFreeLimitExhausted {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(isDark ? premiumGold : Color(hex: "8B5CF6"))
                                .offset(x: 8, y: -4)
                        }
                    }
                    Text(LocalizedStringKey("vault_hard_words"))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    
                    // Badge: count of hard words OR free-tier remaining count
                    hardWordsButtonBadge
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
    
    // MARK: - Button Badge
    /// Shows either:
    ///  • Hard-word count (premium users, or free users who still have sessions & hard words)
    ///  • "X free left" chip (free users with remaining free sessions — subtle scarcity)
    ///  • "Premium" chip (free users with exhausted free sessions)
    @ViewBuilder
    private var hardWordsButtonBadge: some View {
        if premiumManager.isPremium {
            // Premium: just show the hard-word count
            Text("\(vaultVM.hardWordsCount)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
        } else if limitManager.isFreeLimitExhausted {
            // Free limit exhausted: premium CTA chip
            Text(LocalizedStringKey("hard_words_cta_premium"))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "1A1428"))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    LinearGradient(
                        colors: [premiumGold, Color(hex: "D4A017")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        } else {
            // Free with trials remaining: "2 free left" chip (scarcity nudge)
            Text("\(limitManager.remainingFreeSessions) " + NSLocalizedString("hard_words_free_left", comment: ""))
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    LinearGradient(
                        colors: [flameOrange, flameRed],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }

    // MARK: - Handle Hard Words Tap
    /// Gate logic:
    ///  • Premium → open quiz directly
    ///  • Free with trials remaining → open quiz (will record on completion)
    ///  • Free with trials exhausted → paywall
    ///  • 0 hard words → do nothing (button is informational only)
    private func handleHardWordsTap() {
        SoundManager.shared.playClickSound()
        
        // Route free-tier-exhausted users straight to paywall (even with 0 hard words —
        // they're asking to unlock the feature).
        if limitManager.isFreeLimitExhausted {
            showPremiumPaywall = true
            return
        }
        
        // No hard words to quiz on: do nothing (button shows "0").
        guard vaultVM.hardWordsCount > 0 else { return }
        
        // Access granted (premium OR free with remaining sessions).
        showHardReview = true
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
                    .shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 4, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
