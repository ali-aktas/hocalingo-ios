import SwiftUI

// MARK: - StudyView
struct StudyView: View {
    @StateObject private var viewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    @Namespace private var cardNamespace
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Progress Indicator (DYNAMIC)
                    StudyProgressBar(
                        currentIndex: viewModel.currentCardIndex,
                        totalCards: viewModel.totalCards
                    )
                    
                    // Flashcard with smooth transition
                    ZStack {
                        if viewModel.totalCards > 0 {
                            StudyFlashCard(
                                card: viewModel.currentCard,
                                isFlipped: viewModel.isCardFlipped,
                                onTap: { viewModel.flipCard() }
                            )
                            .matchedGeometryEffect(id: "card", in: cardNamespace)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentCardIndex)
                    
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Çalışma")
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

// MARK: - Progress Bar (DYNAMIC like Android)
struct StudyProgressBar: View {
    let currentIndex: Int
    let totalCards: Int
    
    var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(currentIndex) / Double(totalCards)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(currentIndex + 1)/\(totalCards)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress
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

// MARK: - Flashcard with Colors
struct StudyFlashCard: View {
    let card: StudyCard
    let isFlipped: Bool
    let onTap: () -> Void
    
    // Card colors (like Android)
    private var cardColor: Color {
        Color(hex: "FFFFFF")
    }
    
    var body: some View {
        ZStack {
            // Back side
            CardSide(text: card.backText, backgroundColor: cardColor)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Front side
            CardSide(text: card.frontText, backgroundColor: cardColor)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                onTap()
            }
        }
    }
}

struct CardSide: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
            
            Text(text)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(32)
        }
    }
}

// MARK: - Action Buttons (WITH TIME TEXT like Android)
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
            // Tap instruction
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
            // Difficulty buttons
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

// MARK: - Difficulty Button (3D Style like Android)
struct DifficultyButton: View {
    let mainText: String
    let timeText: String
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Main text
            Text(mainText)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            // Time text
            Text(timeText)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Shadow layer (bottom)
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.7))
                    .offset(y: isPressed ? 2 : 4)
                
                // Main layer (top)
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .offset(y: isPressed ? 2 : 0)
            }
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            // Press animation
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onTap()
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

