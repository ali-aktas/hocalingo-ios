//
//  StudyView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN: Full-screen, perfect FlipCard, Ad support - Android parity
//  Location: HocaLingo/Features/Study/StudyView.swift
//

import SwiftUI

// MARK: - Study View
struct StudyView: View {
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isSessionComplete {
                // Completion screen
                StudyCompletionView(
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
                    // ✅ Sesi sadece ekran açıldığında aktifleştir
                    viewModel.onViewAppear()
                }
                .navigationBarHidden(true)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isSessionComplete)
    }
    
    private var studyInterface: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                StudyTopBar(onClose: { dismiss() })
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
                
                // ✅ Main content: Either ad overlay or flashcard
                if viewModel.showNativeAd {
                    // Native Ad Placeholder (Premium users won't see this)
                    NativeAdPlaceholder(onClose: {
                        viewModel.closeNativeAd()
                    })
                    .padding(.horizontal, 16)
                } else if viewModel.studyQueue.count > 0 {
                    // ✅ NEW: Perfect FlipCard component
                    StudyFlipCard(
                        card: viewModel.currentCard,
                        isFlipped: viewModel.isCardFlipped,
                        cardColor: viewModel.currentCardColor,
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
                    StudyEmptyStateView()
                }
                
                Spacer(minLength: 20)
                
                // Action buttons
                if !viewModel.showNativeAd && viewModel.studyQueue.count > 0 {
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
        .navigationBarHidden(true)  // ✅ Full-screen (hide default nav)
    }
}

// MARK: - Top Bar
struct StudyTopBar: View {
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("study_navbar_title")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Settings button (placeholder)
            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.system(size: 16, weight: .semibold))
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
                .font(.system(size: 14, weight: .medium))
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
                    .font(.system(size: 16, weight: .medium))
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
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(timeText)
                    .font(.system(size: 11, weight: .medium))
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

// MARK: - Native Ad Placeholder
struct NativeAdPlaceholder: View {
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(maxWidth: .infinity)
                .aspectRatio(0.7, contentMode: .fit)
            
            VStack(spacing: 16) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.gray.opacity(0.4))
                
                Text("Reklam Alanı")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Text("Premium'a geç, reklamsız çalış!")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: onClose) {
                    Text("Kapat")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding(32)
        }
    }
}

// MARK: - Preview
#Preview {
    StudyView()
}
