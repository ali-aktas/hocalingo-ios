//
//  WordSelectionView.swift
//  HocaLingo
//
//  Location: Features/Selection/WordSelectionView.swift
//

import SwiftUI

// MARK: - Word Selection View
struct WordSelectionView: View {
    let packageId: String
    @Binding var selectedTab: Int

    @StateObject private var viewModel: WordSelectionViewModel
    @State private var showPremiumSheet = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    init(packageId: String, selectedTab: Binding<Int>) {
        self.packageId = packageId
        self._selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: isDarkMode
                    ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                    : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)

            // Content
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer(); loadingView; Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer(); errorView(error); Spacer()
                } else if viewModel.isCompleted {
                    Spacer(); completionView; Spacer()
                } else {
                    mainContent
                }
            }

            // Limit overlay
            if viewModel.selectionLimitReached {
                selectionLimitOverlay
            }
        }
        .navigationTitle("HocaLingo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeAccentColor)
                }
            }
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumPaywallView()
        }
    }

    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16)

            Text(LocalizedStringKey("word_selection_instruction"))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Progress bar + remaining count — single row, no overflow
            progressRow
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            // Daily selection warning banner
            if viewModel.showSelectionWarning, let remaining = viewModel.remainingSelections {
                selectionWarningBanner(remaining: remaining)
            }

            // Card stack
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    // ── NEXT CARD PREVIEW ────────────────────────────────────
                    // Using the identical SwipeableCardView (non-interactive) so
                    // the visual appearance is pixel-perfect to the current card.
                    // When the current card flies away there is no format jump.
                    if let nextWord = viewModel.nextWord {
                        SwipeableCardView(
                            word: nextWord.english,
                            translation: nextWord.turkish,
                            cardColor: cardColor(for: nextWord),
                            onSwipeLeft: {},
                            onSwipeRight: {}
                        )
                        .allowsHitTesting(false)   // non-interactive
                        .scaleEffect(0.95)
                        .offset(y: 10)
                        .opacity(0.55)
                    }

                    // ── CURRENT CARD ─────────────────────────────────────────
                    // .transition(.identity) — no scale/opacity insertion animation.
                    // The card was already visually present as the preview above,
                    // so an insertion animation would create a double-render flash.
                    // The outgoing card handles its own exit via internal offset.
                    if let currentWord = viewModel.currentWord {
                        SwipeableCardView(
                            word: currentWord.english,
                            translation: currentWord.turkish,
                            cardColor: cardColor(for: currentWord),
                            onSwipeLeft: { viewModel.swipeLeft() },
                            onSwipeRight: { viewModel.swipeRight() }
                        )
                        .id(viewModel.cardTransitionId)
                        .transition(.identity)
                    }
                }

                // Undo button — icon only, no background circle
                if viewModel.canUndo {
                    Button(action: { viewModel.undoLastAction() }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.trailing, 28)
                    .padding(.bottom, 28)
                }
            }
            .frame(maxHeight: 460)
            .padding(.horizontal, 20)

            Spacer()

            actionButtons
                .padding(.bottom, 24)
        }
    }

    // MARK: - Progress Row (bar + remaining count, same line)
    private var progressRow: some View {
        HStack(spacing: 12) {
            // Bar — shrinks right-to-left as cards are processed
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeAccentColor)
                        .frame(width: geo.size.width * viewModel.sessionProgress, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.sessionProcessed)
                }
            }
            .frame(height: 6)

            // Remaining count — fixed width so bar never overflows
            Text("\(viewModel.cardsRemaining)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(themeAccentColor)
                .monospacedDigit()
                .frame(minWidth: 28, alignment: .trailing)
        }
    }

    // MARK: - Daily Limit Warning Banner
    private func selectionWarningBanner(remaining: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13))
                .foregroundColor(.orange)

            (Text("\(remaining) ").bold() + Text(LocalizedStringKey("word_selection_remaining")))
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }

    // MARK: - Action Buttons
    // Opacity is NOT tied to isProcessingSwipe — the ViewModel guard already
    // blocks double-fires. Removing opacity change eliminates the dim/bright
    // flash users were seeing on every card transition.
    private var actionButtons: some View {
        HStack(spacing: 24) {
            // Skip (left)
            Button(action: { viewModel.swipeLeft() }) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "EF5350"), Color(hex: "E53935")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 85, height: 85)
                            .shadow(color: Color(hex: "EF5350").opacity(0.35), radius: 10, x: 0, y: 5)

                        Image(systemName: "xmark")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text(LocalizedStringKey("word_selection_skip"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                }
            }
            .allowsHitTesting(!viewModel.isProcessingSwipe)

            // Learn (right)
            Button(action: { viewModel.swipeRight() }) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "66BB6A"), Color(hex: "43A047")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 85, height: 85)
                            .shadow(color: Color(hex: "66BB6A").opacity(0.35), radius: 10, x: 0, y: 5)

                        Image(systemName: "checkmark")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(LocalizedStringKey("word_selection_learn"))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.themePrimary)
                }
            }
            .allowsHitTesting(!viewModel.isProcessingSwipe && !viewModel.selectionLimitReached)
        }
    }

    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(themeAccentColor)

            VStack(spacing: 12) {
                Text(LocalizedStringKey("word_selection_complete_title"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey("word_selection_complete_subtitle"))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 12) {
                if viewModel.selectedCount > 0 {
                    Button(action: {
                        viewModel.navigateToStudy()
                        selectedTab = 1
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                            Text(LocalizedStringKey("word_selection_start_learning"))
                            Text("(\(viewModel.selectedCount))")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(themeAccentColor)
                        .cornerRadius(16)
                        .shadow(color: themeAccentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }

                Button(action: { dismiss() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2.fill")
                        Text(LocalizedStringKey("word_selection_new_package"))
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(themeAccentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(themeAccentColor.opacity(0.12))
                    .cornerRadius(16)
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        )
        .padding(.horizontal, 40)
    }

    // MARK: - Selection Limit Overlay
    private var selectionLimitOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { viewModel.selectionLimitReached = false }

            VStack(spacing: 24) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)

                VStack(spacing: 8) {
                    Text(LocalizedStringKey("word_selection_limit_title"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    // Shortened — was a long paragraph, now one concise line
                    Text(LocalizedStringKey("word_selection_limit_short"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    if viewModel.selectedCount > 0 {
                        Button(action: {
                            viewModel.selectionLimitReached = false
                            selectedTab = 1
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "book.fill")
                                Text(LocalizedStringKey("word_selection_start_learning"))
                                Text("(\(viewModel.selectedCount))")
                            }
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(themeAccentColor)
                            .cornerRadius(14)
                        }
                    }

                    Button(action: {
                        viewModel.selectionLimitReached = false
                        showPremiumSheet = true
                    }) {
                        Text(LocalizedStringKey("premium_badge_upgrade"))
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(themeAccentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(themeAccentColor.opacity(0.12))
                            .cornerRadius(14)
                    }
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 36)
        }
    }

    // MARK: - Loading / Error Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text(LocalizedStringKey("loading"))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Theme
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private var backgroundColor: Color {
        isDarkMode ? Color(hex: "1A1625") : Color(hex: "FBF2FF")
    }
    private var themeAccentColor: Color { Color(hex: "4ECDC4") }

    private func cardColor(for word: Word) -> Color {
        let colors = [
            Color(hex: "5C6BC0"), Color(hex: "42A5F5"),
            Color(hex: "26C6DA"), Color(hex: "66BB6A"),
            Color(hex: "FFA726"), Color(hex: "EF5350")
        ]
        return colors[word.id % colors.count]
    }
}

// MARK: - Preview
struct WordSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WordSelectionView(packageId: "en_tr_a1_001", selectedTab: .constant(0))
        }
        .environment(\.themeViewModel, ThemeViewModel.shared)
    }
}
