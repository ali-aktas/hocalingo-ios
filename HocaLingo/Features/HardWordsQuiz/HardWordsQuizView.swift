//
//  HardWordsQuizView.swift
//  HocaLingo
//
//  Hard Words Quiz - Premium quiz UI
//  3-option EN→TR quiz with animations and session tracking
//  Location: Features/HardWordsQuiz/HardWordsQuizView.swift
//

import SwiftUI

// MARK: - Hard Words Quiz View
struct HardWordsQuizView: View {

    @StateObject private var viewModel = HardWordsQuizViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    // ✅ V2: Observe limit manager + premium status for result-screen CTA
    @ObservedObject private var limitManager = HardWordsQuizLimitManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showPaywallFromResult = false

    // Animation states
    @State private var questionScale: CGFloat = 1.0
    @State private var showCorrectGlow = false
    @State private var shakeOffset: CGFloat = 0
    @State private var streakScale: CGFloat = 1.0
    @State private var graduationOverlay = false
    @State private var graduatedWordName = ""

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private var accent: Color { Color(hex: "8B5CF6") }
    private var correctColor: Color { Color(hex: "10B981") }
    private var wrongColor: Color { Color(hex: "EF4444") }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: isDark
                    ? [Color(hex: "1A1625"), Color(hex: "211A2E")]
                    : [Color(hex: "FBF2FF"), Color(hex: "FAF1FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(accent.opacity(isDark ? 0.12 : 0.06))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 100, y: -200)
                .allowsHitTesting(false)

            switch viewModel.sessionState {
            case .playing:
                quizContent
            case .sessionComplete:
                resultScreen
            }

            // Graduation celebration overlay
            if graduationOverlay {
                graduationCelebration
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        // ✅ V2: Paywall from "Get Premium" CTA on result screen
        .sheet(isPresented: $showPaywallFromResult) {
            PremiumPaywallView()
        }
    }

    // MARK: - Quiz Content
    private var quizContent: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
                .padding(.horizontal, 24)
                .padding(.top, 16)

            // Progress bar
            progressBar
                .padding(.horizontal, 24)
                .padding(.top, 12)

            // Streak indicator
            if viewModel.stats.streak >= 2 {
                streakBadge
                    .padding(.top, 16)
            }

            Spacer()

            // Question card
            if let question = viewModel.currentQuestion {
                questionCard(question)
                    .padding(.horizontal, 24)
                    .scaleEffect(questionScale)
                    .offset(x: shakeOffset)
            }

            Spacer()

            // Options
            if let question = viewModel.currentQuestion {
                optionButtons(question)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }

            // Next button (appears after answering)
            if viewModel.answerState != .unanswered {
                nextButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Spacer().frame(height: 80)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.answerState != .unanswered)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey("quiz_title"))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("\(viewModel.currentIndex + 1) / \(viewModel.totalQuestions)")
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
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.1))
                    .frame(height: 5)
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * viewModel.progressFraction, height: 5)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.currentIndex)
            }
        }
        .frame(height: 5)
    }

    // MARK: - Streak Badge
    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "F97316"))
            Text("\(viewModel.stats.streak)")
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundColor(Color(hex: "F97316"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(hex: "F97316").opacity(isDark ? 0.15 : 0.1))
        )
        .scaleEffect(streakScale)
        .onChange(of: viewModel.stats.streak) { _, newValue in
            if newValue >= 2 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    streakScale = 1.25
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                    streakScale = 1.0
                }
            }
        }
    }

    // MARK: - Question Card
    private func questionCard(_ question: QuizQuestion) -> some View {
        VStack(spacing: 16) {
            // English word
            Text(question.english)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Hint text
            Text(LocalizedStringKey("quiz_select_meaning"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
                .shadow(color: .black.opacity(isDark ? 0.25 : 0.08), radius: 16, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    showCorrectGlow ? correctColor.opacity(0.6) : Color.clear,
                    lineWidth: 2
                )
        )
    }

    // MARK: - Option Buttons
    private func optionButtons(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options) { option in
                optionButton(option, question: question)
            }
        }
    }

    private func optionButton(_ option: QuizOption, question: QuizQuestion) -> some View {
        let isSelected = viewModel.selectedOptionId == option.id
        let isAnswered = viewModel.answerState != .unanswered
        let showAsCorrect = isAnswered && option.isCorrect
        let showAsWrong = isSelected && !option.isCorrect && isAnswered

        return Button(action: {
            guard viewModel.answerState == .unanswered else { return }
                        let graduatedBefore = viewModel.stats.graduatedWords.count
                        viewModel.selectOption(option)
                        animateAnswer(correct: option.isCorrect, graduatedBefore: graduatedBefore, question: question)
        }) {
            HStack(spacing: 14) {
                // Status icon
                ZStack {
                    Circle()
                        .fill(optionCircleColor(showAsCorrect: showAsCorrect, showAsWrong: showAsWrong, isAnswered: isAnswered))
                        .frame(width: 32, height: 32)

                    if showAsCorrect {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else if showAsWrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                }

                // Option text
                Text(option.text)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(optionBackground(showAsCorrect: showAsCorrect, showAsWrong: showAsWrong, isAnswered: isAnswered))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(optionBorder(showAsCorrect: showAsCorrect, showAsWrong: showAsWrong, isAnswered: isAnswered), lineWidth: 2)
            )
        }
        .disabled(isAnswered)
        .scaleEffect(isSelected && isAnswered ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isAnswered)
    }

    // MARK: - Option Styling Helpers
    private func optionCircleColor(showAsCorrect: Bool, showAsWrong: Bool, isAnswered: Bool) -> Color {
        if showAsCorrect { return correctColor }
        if showAsWrong { return wrongColor }
        return .clear
    }

    private func optionBackground(showAsCorrect: Bool, showAsWrong: Bool, isAnswered: Bool) -> Color {
        if showAsCorrect { return correctColor.opacity(isDark ? 0.12 : 0.08) }
        if showAsWrong { return wrongColor.opacity(isDark ? 0.12 : 0.08) }
        return isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.85)
    }

    private func optionBorder(showAsCorrect: Bool, showAsWrong: Bool, isAnswered: Bool) -> Color {
        if showAsCorrect { return correctColor.opacity(0.5) }
        if showAsWrong { return wrongColor.opacity(0.5) }
        return isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }

    // MARK: - Next Button
    private var nextButton: some View {
        Button(action: {
            // Check if a word just graduated
            let graduatedBefore = viewModel.stats.graduatedWords
            viewModel.nextQuestion()
            let graduatedAfter = viewModel.stats.graduatedWords

            // If we just graduated AND still playing, show celebration
            // Actually graduation happens on selectOption, so check there
        }) {
            HStack(spacing: 8) {
                Text(viewModel.currentIndex < viewModel.totalQuestions - 1
                     ? LocalizedStringKey("quiz_next")
                     : LocalizedStringKey("quiz_see_results"))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Image(systemName: viewModel.currentIndex < viewModel.totalQuestions - 1
                      ? "arrow.right" : "chart.bar.fill")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: viewModel.answerState == .correct
                        ? [correctColor, correctColor.opacity(0.8)]
                        : [accent, accent.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: (viewModel.answerState == .correct ? correctColor : accent).opacity(0.3),
                radius: 10, y: 4
            )
        }
    }

    // MARK: - Animations
    private func animateAnswer(correct: Bool, graduatedBefore: Int, question: QuizQuestion) {
        if correct {
            // Correct: green glow + scale bounce
            withAnimation(.easeInOut(duration: 0.3)) { showCorrectGlow = true }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { questionScale = 1.05 }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) { questionScale = 1.0 }

            // Check graduation with slight delay for UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if viewModel.stats.graduatedWords.count > graduatedBefore {
                    graduatedWordName = viewModel.stats.graduatedWords.last ?? question.english
                    withAnimation(.easeInOut(duration: 0.3)) { graduationOverlay = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.3)) { graduationOverlay = false }
                    }
                }
            }
        } else {
            // Wrong: shake
            withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) { shakeOffset = -12 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) { shakeOffset = 12 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) { shakeOffset = -8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) { shakeOffset = 0 }
            }
        }

        // Reset glow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { showCorrectGlow = false }
        }
    }

    // MARK: - Graduation Celebration
    private var graduationCelebration: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Color(hex: "FFD700"))
                    .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 20)

                Text(LocalizedStringKey("quiz_word_graduated"))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(graduatedWordName)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .scaleEffect(graduationOverlay ? 1.0 : 0.5)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: graduationOverlay)
        }
    }

    // MARK: - Result Screen
    private var resultScreen: some View {
        VStack(spacing: 0) {
            Spacer()

            // Result icon
            ZStack {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: resultIcon)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(accent)
            }
            .padding(.bottom, 24)

            // Title
            Text(LocalizedStringKey("quiz_session_complete"))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            // Stats cards
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    statCard(
                        icon: "checkmark.circle.fill",
                        value: "\(viewModel.stats.correctCount)",
                        labelKey: "quiz_correct",
                        color: correctColor
                    )
                    statCard(
                        icon: "xmark.circle.fill",
                        value: "\(viewModel.stats.wrongCount)",
                        labelKey: "quiz_wrong",
                        color: wrongColor
                    )
                }
                HStack(spacing: 12) {
                    statCard(
                        icon: "flame.fill",
                        value: "\(viewModel.stats.bestStreak)",
                        labelKey: "quiz_best_streak",
                        color: Color(hex: "F97316")
                    )
                    statCard(
                        icon: "star.fill",
                        value: "\(viewModel.stats.graduatedWords.count)",
                        labelKey: "quiz_graduated",
                        color: Color(hex: "FFD700")
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            // Graduated words list
            if !viewModel.stats.graduatedWords.isEmpty {
                VStack(spacing: 8) {
                    Text(LocalizedStringKey("quiz_graduated_list"))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)

                    Text(viewModel.stats.graduatedWords.joined(separator: ", "))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "FFD700"))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.horizontal, 32)
            }

            // ✅ V2: Free-tier status CTA — shown only to free users
            if !premiumManager.isPremium {
                freeTierResultCTA
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                // Continue studying (if there are remaining hard words)
                Button(action: { viewModel.startNewSession() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 15, weight: .bold))
                        Text(LocalizedStringKey("quiz_continue_studying"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: accent.opacity(0.3), radius: 10, y: 4)
                }

                // Close
                Button(action: { dismiss() }) {
                    Text(LocalizedStringKey("quiz_done"))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
    }

    private var resultIcon: String {
        let ratio = viewModel.stats.totalQuestions > 0
            ? Double(viewModel.stats.correctCount) / Double(viewModel.stats.totalQuestions)
            : 0
        if ratio >= 0.8 { return "trophy.fill" }
        if ratio >= 0.5 { return "hand.thumbsup.fill" }
        return "book.fill"
    }

    // MARK: - Free Tier Result CTA (V2)
        /// Appears on the result screen for free users:
        ///  • Shows remaining free sessions OR "out of tries" message
        ///  • Offers a direct paywall button
        /// Also records the completed session when this view renders (once per session).
        @ViewBuilder
        private var freeTierResultCTA: some View {
            let remaining = limitManager.remainingFreeSessions
            let isLast = remaining == 0
            
            VStack(spacing: 12) {
                // Scarcity message
                HStack(spacing: 8) {
                    Image(systemName: isLast ? "lock.fill" : "hourglass")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isLast ? Color(hex: "EF4444") : Color(hex: "F97316"))
                    
                    if isLast {
                        Text(LocalizedStringKey("hard_words_cta_exhausted"))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    } else {
                        (Text("\(remaining) ") + Text(LocalizedStringKey("hard_words_cta_remaining")))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                
                // Premium CTA button
                Button(action: {
                    SoundManager.shared.playClickSound()
                    showPaywallFromResult = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text(LocalizedStringKey("hard_words_cta_unlock"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "1A1428"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "D4A017")],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color(hex: "FFD700").opacity(0.4), radius: 10, y: 4)
                }
            }
        }
    
    // MARK: - Stat Card
    private func statCard(icon: String, value: String, labelKey: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
            Text(LocalizedStringKey(labelKey))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
                .shadow(color: .black.opacity(isDark ? 0.2 : 0.06), radius: 6, y: 2)
        )
    }
}
