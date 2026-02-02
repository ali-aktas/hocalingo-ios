//
//  StudyView.swift
//  HocaLingo
//
//  ✅ UPDATED: Ad system removed + Settings button active + Card style support
//  Location: HocaLingo/Features/Study/StudyView.swift
//

import SwiftUI

// MARK: - Study View
struct StudyView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isSessionComplete {
                // Completion screen
                StudyCompletionView(
                    selectedTab: $selectedTab,
                    onContinue: { dismiss() },
                    onRestart: { dismiss() }
                )
                .transition(.opacity)
            } else {
                // Normal study UI
                studyInterface
            }
        }
        .onAppear {
            viewModel.onViewAppear()
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSessionComplete)
        .sheet(isPresented: $viewModel.showStyleSettings) {
            // ✅ NEW: Card style settings sheet
            CardStyleSettingsView(viewModel: viewModel)
        }
    }
    
    private var studyInterface: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                StudyTopBar(
                    onClose: {
                        selectedTab = 0
                    },
                    onSettings: {
                        viewModel.showStyleSettings = true  // ✅ NEW: Open settings
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
                
                // ✅ UPDATED: FlipCard with new props (no ads)
                if viewModel.studyQueue.count > 0 {
                    StudyFlipCard(
                        card: viewModel.currentCard,
                        isFlipped: viewModel.isCardFlipped,
                        cardColor: viewModel.currentCardColor,
                        cardGradient: viewModel.currentCardGradient,  // ✅ NEW
                        cardStyle: viewModel.cardStyle,               // ✅ NEW
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
                    // Empty state
                    StudyEmptyStateView(selectedTab: $selectedTab)
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
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Top Bar
struct StudyTopBar: View {
    let onClose: () -> Void
    let onSettings: () -> Void  // ✅ NEW: Settings action
    
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
            
            // ✅ UPDATED: Settings button (now active)
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
                    title: "Zor",
                    timeText: hardTime,
                    color: Color(hex: "EF4444"),
                    isEnabled: true,
                    onTap: onHard
                )
                
                // Medium button
                StudyActionButton(
                    title: "Orta",
                    timeText: mediumTime,
                    color: Color(hex: "F97316"),
                    isEnabled: true,
                    onTap: onMedium
                )
                
                // Easy button
                StudyActionButton(
                    title: "Kolay",
                    timeText: easyTime,
                    color: Color(hex: "10B981"),
                    isEnabled: true,
                    onTap: onEasy
                )
            }
        } else {
            // Flip card prompt
            Button(action: {}) {
                Text("study_flip_card_hint")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "D1C4E9"))
                    .cornerRadius(18)
            }
            .disabled(true)
            .opacity(0.5)
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
