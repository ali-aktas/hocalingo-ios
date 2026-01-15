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
            .onChange(of: viewModel.shouldDismiss) {
                if viewModel.shouldDismiss {
                    dismiss()
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
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    // Progress fill
                    Rectangle()
                        .fill(Color(hex: "4CAF50"))
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            // Progress text
            HStack {
                Text("\(currentIndex + 1) / \(totalWords)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
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
            // Back side
            CardSide(text: backText, backgroundColor: Color(hex: "FFFFFF"))
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Front side
            CardSide(text: frontText, backgroundColor: Color(hex: "FFFFFF"))
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                onTap()
            }
        }
    }
}

// MARK: - Card Side
struct CardSide: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            
            Text(text)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
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
            // Hard button
            Button(action: onHard) {
                VStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                    Text("Hard")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "F44336"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Medium button
            Button(action: onMedium) {
                VStack(spacing: 4) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                    Text("Medium")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "FF9800"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            
            // Easy button
            Button(action: onEasy) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                    Text("Easy")
                        .font(.system(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "4CAF50"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// MARK: - Preview
struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
