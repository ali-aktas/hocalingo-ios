//
//  StudyView.swift
//  HocaLingo
//
//  ✅ UPDATED: Ad system removed + Settings button active + Card style support
//  ✅ FIX: Package selection sheets lifted here to survive view hierarchy changes
//  Location: HocaLingo/Features/Study/StudyView.swift
//

import SwiftUI
import Lottie

// MARK: - Study View
struct StudyView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme

    // ✅ FIX: Sheet lifted here so it survives StudyEmptyStateView being removed
    @State private var showEmptyStatePackageSelection = false
    @State private var emptyStatePackageTab: Int = 0
    @State private var showStudyHint = false
    
    // ✅ FIX: Sheet lifted here so it survives StudyCompletionView being removed
    @State private var showCompletionPackageSelection = false
    @State private var completionPackageTab: Int = 0
    
    var body: some View {
        ZStack {
            if viewModel.isSessionComplete {
                // Completion screen — passes binding so button triggers sheet above
                StudyCompletionView(
                    selectedTab: $selectedTab,
                    onContinue: { dismiss() },
                    onRestart: { dismiss() },
                    showPackageSelection: $showCompletionPackageSelection
                )
                .transition(.opacity)
            } else {
                // Normal study UI
                studyInterface
            }
        }
        .onAppear {
            viewModel.onViewAppear()
            checkNotificationNavigation()
            if shouldShowHint(for: "has_seen_study_hint") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    showStudyHint = true
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSessionComplete)
        .sheet(isPresented: $viewModel.showStyleSettings) {
            CardStyleSettingsView(viewModel: viewModel)
        }
        // ✅ FIX: Empty state package selection sheet
        .sheet(isPresented: $showEmptyStatePackageSelection) {
            PackageSelectionView(selectedTab: $emptyStatePackageTab)
                .onDisappear {
                    if emptyStatePackageTab == 1 {
                        selectedTab = 1
                    }
                    emptyStatePackageTab = 0
                }
        }
        // ✅ FIX: Completion state package selection sheet
        .sheet(isPresented: $showCompletionPackageSelection) {
            PackageSelectionView(selectedTab: $completionPackageTab)
                .onDisappear {
                    if completionPackageTab == 1 {
                        selectedTab = 1
                    }
                    completionPackageTab = 0
                }
        }
        // ✅ FIX: Pause queue reload while empty state sheet is open
        .onChange(of: showEmptyStatePackageSelection) { _, isOpen in
            viewModel.isPackageSelectionActive = isOpen
            if !isOpen {
                viewModel.loadStudyQueue()
            }
        }
        // ✅ FIX: Pause queue reload while completion sheet is open
        .onChange(of: showCompletionPackageSelection) { _, isOpen in
            viewModel.isPackageSelectionActive = isOpen
            if !isOpen {
                viewModel.loadStudyQueue()
            }
        }
    }
    
    
    private func checkNotificationNavigation() {
            if UserDefaults.standard.bool(forKey: "should_navigate_to_study") {
                UserDefaults.standard.set(false, forKey: "should_navigate_to_study")
                
                if viewModel.studyQueue.count < 15 {
                    selectedTab = 0
                    NotificationCenter.default.post(
                        name: NSNotification.Name("OpenPackageSelection"),
                        object: nil
                    )
                }
            }
        }
    
    private var studyInterface: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hex: "1A1625"),
                    Color(hex: "211A2E")
                ] : [
                    Color(hex: "FBF2FF"),
                    Color(hex: "FAF1FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
            
            VStack(spacing: 0) {
                // Top bar
                StudyTopBar(
                    onClose: {
                        selectedTab = 0
                    },
                    onSettings: {
                        viewModel.showStyleSettings = true
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Progress indicator
                if viewModel.studyQueue.count > 0 {
                    StudyProgressBar(
                        currentIndex: viewModel.currentCardIndex,
                        totalCards: viewModel.studyQueue.count
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                Spacer(minLength: 20)
                
                if viewModel.studyQueue.count > 0 {
                    StudyFlipCard(
                        card: viewModel.currentCard,
                        isFlipped: viewModel.isCardFlipped,
                        cardColor: viewModel.currentCardColor,
                        cardGradient: viewModel.currentCardGradient,
                        cardStyle: viewModel.cardStyle,
                        exampleSentence: viewModel.currentExampleSentence,
                        shouldShowSpeakerOnFront: viewModel.shouldShowSpeakerOnFront == true,
                        isCardFlipped: viewModel.isCardFlipped,
                        onTap: { viewModel.flipCard() },
                        onSpeakerTap: { viewModel.replayAudio() }
                    )
                    .padding(.horizontal, 24)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                } else {
                    // ✅ FIX: binding passed so button triggers sheet above
                    StudyEmptyStateView(
                        selectedTab: $selectedTab,
                        showPackageSelection: $showEmptyStatePackageSelection,
                        isFirstTime: UserDefaultsManager.shared.loadUserStats().totalWordsStudied == 0
                    )
                }
                
                Spacer(minLength: 20)
                
                // Action buttons
                if viewModel.studyQueue.count > 0 {
                    StudyButtons(
                        isCardFlipped: viewModel.isCardFlipped,
                        hardTime: viewModel.hardTimeText,
                        mediumTime: viewModel.mediumTimeText,
                        easyTime: viewModel.easyTimeText,
                        onHard: { viewModel.answerCard(difficulty: .hard) },
                        onMedium: { viewModel.answerCard(difficulty: .medium) },
                        onEasy: { viewModel.answerCard(difficulty: .easy) }
                    )
                        .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                    }
                }
                                
                // Study hint overlay (first time only)
                SwipeHintOverlay(
                    hintTextKey: "swipe_hint_study",
                    userDefaultsKey: "has_seen_study_hint",
                    isVisible: $showStudyHint
                )
            }
            .navigationBarHidden(true)
        }
            
            var isDarkMode: Bool {
            themeViewModel.isDarkMode(in: colorScheme)
    }
}


// MARK: - Top Bar
struct StudyTopBar: View {
    let onClose: () -> Void
    let onSettings: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("study_navbar_title")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Progress Bar
struct StudyProgressBar: View {
    let currentIndex: Int
    let totalCards: Int
    
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentIndex + 1) / Double(totalCards)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(currentIndex + 1)/\(totalCards)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "4ECDC4"))
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.spring(response: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Study Buttons (Hard, Medium, Easy)
struct StudyButtons: View {
    let isCardFlipped: Bool
    let hardTime: String
    let mediumTime: String
    let easyTime: String
    let onHard: () -> Void
    let onMedium: () -> Void
    let onEasy: () -> Void
    
    var body: some View {
        if isCardFlipped {
            HStack(spacing: 12) {
                // Hard button
                StudyActionButton(
                    title: NSLocalizedString("study_hard", comment: ""),
                    timeText: hardTime,
                    color: Color(hex: "EF4444"),
                    isEnabled: true,
                    onTap: onHard
                )
                
                // Medium button
                StudyActionButton(
                    title: NSLocalizedString("study_medium", comment: ""),
                    timeText: mediumTime,
                    color: Color(hex: "F97316"),
                    isEnabled: true,
                    onTap: onMedium
                )
                
                // Easy button
                StudyActionButton(
                    title: NSLocalizedString("study_easy", comment: ""),
                    timeText: easyTime,
                    color: Color(hex: "10B981"),
                    isEnabled: true,
                    onTap: onEasy
                )
            }
        } else {
            Button(action: {}) {
                Text("study_flip_card_hint")
                    .font(.system(size: 16, weight: .thin, design: .rounded))
                    .foregroundColor(Color(hex: "8B5CF6"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Color(hex: "8B5CF6").opacity(0.12)
                    )
                    .cornerRadius(18)
            }
            .disabled(true)
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Action Button
struct StudyActionButton: View {
    let title: String
    let timeText: String
    let color: Color
    let isEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(timeText)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}
