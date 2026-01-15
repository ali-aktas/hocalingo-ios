import SwiftUI

// MARK: - StudyView
struct StudyView: View {
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "F5F5F5")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Progress Indicator
                    StudyProgressIndicator(
                        currentIndex: viewModel.currentCardIndex,
                        totalWords: viewModel.totalCards,
                        progress: viewModel.progressPercentage
                    )
                    
                    // Flashcard
                    FlashcardView(
                        frontText: viewModel.currentCard.frontText,
                        backText: viewModel.currentCard.backText,
                        isFlipped: viewModel.isCardFlipped,
                        onTap: {
                            viewModel.flipCard()
                        }
                    )
                    .frame(maxHeight: .infinity)
                    
                    // Action Buttons (only show when card is flipped)
                    if viewModel.isCardFlipped {
                        StudyActionButtons(
                            onHard: {
                                viewModel.answerCard(difficulty: .hard)
                            },
                            onMedium: {
                                viewModel.answerCard(difficulty: .medium)
                            },
                            onEasy: {
                                viewModel.answerCard(difficulty: .easy)
                            }
                        )
                    }
                }
                .padding(16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("study_title")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Progress Indicator
struct StudyProgressIndicator: View {
    let currentIndex: Int
    let totalWords: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            // Counter text
            Text("\(currentIndex + 1) / \(totalWords)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Flashcard View
struct FlashcardView: View {
    let frontText: String
    let backText: String
    let isFlipped: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Front side (English word) - visible when NOT flipped
            CardSide(
                text: frontText,
                backgroundColor: .white,
                textColor: .primary
            )
            .rotation3DEffect(
                .degrees(isFlipped ? -180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(isFlipped ? 0 : 1)
            
            // Back side (Turkish translation) - visible when flipped
            // Starts at 180° rotation (facing backward), rotates to 0° when flipped
            CardSide(
                text: backText,
                backgroundColor: Color(hex: "8B5CF6"),
                textColor: .white
            )
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(isFlipped ? 1 : 0)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                onTap()
            }
        }
    }
}

// MARK: - Card Side Component
struct CardSide: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            Text(text)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .padding(32)
        }
    }
}

// MARK: - Action Buttons
struct StudyActionButtons: View {
    let onHard: () -> Void
    let onMedium: () -> Void
    let onEasy: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Hard Button
            DifficultyButton(
                title: "hard_button",
                subtitle: "< 1m",
                color: Color(hex: "EF4444"),
                action: onHard
            )
            
            // Medium Button
            DifficultyButton(
                title: "medium_button",
                subtitle: "< 10m",
                color: Color(hex: "F59E0B"),
                action: onMedium
            )
            
            // Easy Button
            DifficultyButton(
                title: "easy_button",
                subtitle: "4d",
                color: Color(hex: "10B981"),
                action: onEasy
            )
        }
    }
}

// MARK: - Difficulty Button Component
struct DifficultyButton: View {
    let title: LocalizedStringKey
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    StudyView()
}
