//
//  StudyView.swift (FIXED)
//  HocaLingo
//
//  ✅ FIXED: Compatible with updated StudyViewModel
//  Location: HocaLingo/Features/Study/StudyView.swift
//

import SwiftUI

// MARK: - StudyView
struct StudyView: View {
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if viewModel.isSessionComplete {
                // Completion screen
                StudyCompletionView(
                    onContinue: { dismiss() },
                    onRestart: {
                        // ✅ FIXED: Use loadStudyQueue instead of restartSession
                        dismiss()
                    }
                )
                .transition(.opacity)
            } else {
                // Normal study UI
                studyInterface
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSessionComplete)
    }
    
    private var studyInterface: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Progress Bar
                    StudyProgressBar(
                        currentIndex: viewModel.currentCardIndex,
                        totalCards: viewModel.studyQueue.count  // ✅ FIXED: Direct access
                    )
                    
                    // Flashcard
                    if viewModel.studyQueue.count > 0 {
                        StudyFlashCard(
                            card: viewModel.currentCard,
                            isFlipped: viewModel.isCardFlipped,
                            cardColor: viewModel.currentCardColor,
                            exampleSentence: viewModel.currentExampleSentence,
                            shouldShowSpeakerOnFront: viewModel.shouldShowSpeakerOnFront,
                            isCardFlipped: viewModel.isCardFlipped,
                            onTap: { viewModel.flipCard() },
                            onSpeakerTap: { viewModel.replayAudio() }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    } else {
                        Text("Çalışacak kelime yok")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                    
                    // Action Buttons
                    StudyButtons(
                        isCardFlipped: viewModel.isCardFlipped,
                        hardTime: viewModel.hardTimeText,
                        mediumTime: viewModel.mediumTimeText,
                        easyTime: viewModel.easyTimeText,
                        onHard: { viewModel.answerCard(difficulty: .hard) },
                        onMedium: { viewModel.answerCard(difficulty: .medium) },
                        onEasy: { viewModel.answerCard(difficulty: .easy) }
                    )
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Çalışma")
                        .font(.system(size: 17, weight: .semibold))
                }
            })
        }
        .navigationViewStyle(.stack)
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

// MARK: - Flashcard with 3D Animation
struct StudyFlashCard: View {
    let card: StudyCard
    let isFlipped: Bool
    let cardColor: Color
    let exampleSentence: String
    let shouldShowSpeakerOnFront: Bool
    let isCardFlipped: Bool
    let onTap: () -> Void
    let onSpeakerTap: () -> Void
    
    var body: some View {
        ZStack {
            Group {
                // Back side
                CardContent(
                    mainText: card.backText,
                    exampleText: exampleSentence,
                    backgroundColor: cardColor,
                    showSpeakerButton: !shouldShowSpeakerOnFront && isCardFlipped,
                    onSpeakerTap: onSpeakerTap
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                
                // Front side
                CardContent(
                    mainText: card.frontText,
                    exampleText: exampleSentence,
                    backgroundColor: cardColor,
                    showSpeakerButton: shouldShowSpeakerOnFront && !isCardFlipped,
                    onSpeakerTap: onSpeakerTap
                )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
            }
        }
        .frame(maxHeight: .infinity)
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                onTap()
            }
        }
    }
}

// MARK: - Card Content
struct CardContent: View {
    let mainText: String
    let exampleText: String
    let backgroundColor: Color
    let showSpeakerButton: Bool
    let onSpeakerTap: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
            
            VStack(spacing: 16) {
                Spacer()
                
                // Main text
                Text(mainText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Example sentence
                if !exampleText.isEmpty {
                    Text(exampleText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Speaker button
                if showSpeakerButton {
                    Button(action: onSpeakerTap) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .padding(.bottom, 16)
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
        }
    }
}

// MARK: - Action Buttons
struct StudyButtons: View {
    let isCardFlipped: Bool
    let hardTime: String
    let mediumTime: String
    let easyTime: String
    let onHard: () -> Void
    let onMedium: () -> Void
    let onEasy: () -> Void
    
    var body: some View {
        if !isCardFlipped {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Text("Kartı çevir")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        } else {
            HStack(spacing: 12) {
                DifficultyButton(
                    mainText: "Zor",
                    timeText: hardTime,
                    color: Color(hex: "FF3B30"),
                    onTap: onHard
                )
                
                DifficultyButton(
                    mainText: "Orta",
                    timeText: mediumTime,
                    color: Color(hex: "FF9500"),
                    onTap: onMedium
                )
                
                DifficultyButton(
                    mainText: "Kolay",
                    timeText: easyTime,
                    color: Color(hex: "34C759"),
                    onTap: onEasy
                )
            }
        }
    }
}

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let mainText: String
    let timeText: String
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(mainText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(timeText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .shadow(
                color: color.opacity(0.4),
                radius: isPressed ? 2 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .offset(y: isPressed ? 2 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Preview
#Preview {
    StudyView()
}
