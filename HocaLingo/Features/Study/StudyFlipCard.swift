//
//  StudyFlipCard.swift
//  HocaLingo
//
//  ✅ UPDATED: 3 card styles support (colorful, minimal, premium)
//  Location: HocaLingo/Features/Study/StudyFlipCard.swift
//

import SwiftUI

// MARK: - Study Flip Card
/// Premium 3D flip card with 3 design styles
///
/// Styles:
/// 1. Colorful: Random vibrant colors (default)
/// 2. Minimal: Single grey color (clean design)
/// 3. Premium: Beautiful gradients (Premium users only)
struct StudyFlipCard: View {
    
    // MARK: - Properties
    let card: StudyCard
    let isFlipped: Bool
    let cardColor: Color
    let cardGradient: [Color]?  // ✅ NEW: For premium style
    let cardStyle: CardStyle     // ✅ NEW: Card style
    let exampleSentence: String
    let shouldShowSpeakerOnFront: Bool
    let isCardFlipped: Bool
    let onTap: () -> Void
    let onSpeakerTap: () -> Void
    
    // MARK: - Animation State
    @State private var rotation: Double = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // ✅ 3D depth shadow
            depthShadow
            
            // ✅ Main card with perfect flip
            mainCard
        }
        .onChange(of: isFlipped) { _, newValue in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                rotation = newValue ? 180 : 0
            }
        }
        .onAppear {
            rotation = isFlipped ? 180 : 0
        }
    }
    
    // MARK: - Depth Shadow (3D Effect)
    private var depthShadow: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.black.opacity(0.18))
            .frame(maxWidth: .infinity)
            .aspectRatio(0.7, contentMode: .fit)
            .offset(y: 8)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
    }
    
    // MARK: - Main Card
    private var mainCard: some View {
        ZStack {
            // Back side (flipped state)
            CardFace(
                mainText: card.backText,
                exampleText: exampleSentence,
                backgroundColor: cardColor,
                backgroundGradient: cardGradient,
                cardStyle: cardStyle,
                showSpeakerButton: !shouldShowSpeakerOnFront && isCardFlipped,
                onSpeakerTap: onSpeakerTap,
                isFront: false
            )
            .opacity(rotation > 90 ? 1 : 0)
            .rotation3DEffect(
                .degrees(rotation - 180),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            
            // Front side (default state)
            CardFace(
                mainText: card.frontText,
                exampleText: exampleSentence,
                backgroundColor: cardColor,
                backgroundGradient: cardGradient,
                cardStyle: cardStyle,
                showSpeakerButton: shouldShowSpeakerOnFront && !isCardFlipped,
                onSpeakerTap: onSpeakerTap,
                isFront: true
            )
            .opacity(rotation <= 90 ? 1 : 0)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.7, contentMode: .fit)
        .shadow(
            color: shadowColor,
            radius: dynamicShadowRadius,
            x: 0,
            y: dynamicShadowOffset
        )
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Dynamic Shadow (Style-Aware)
    private var shadowColor: Color {
        switch cardStyle {
        case .colorful:
            return cardColor.opacity(dynamicShadowOpacity)
        case .minimal:
            return Color.gray.opacity(dynamicShadowOpacity * 0.5)
        case .premium:
            return (cardGradient?.first ?? cardColor).opacity(dynamicShadowOpacity)
        }
    }
    
    private var dynamicShadowOpacity: Double {
        let normalized = abs(rotation - 90) / 90
        return 0.3 * (1 - normalized) + 0.15 * normalized
    }
    
    private var dynamicShadowRadius: CGFloat {
        let normalized = abs(rotation - 90) / 90
        return 18 * (1 - normalized) + 8 * normalized
    }
    
    private var dynamicShadowOffset: CGFloat {
        let normalized = abs(rotation - 90) / 90
        return 12 * (1 - normalized) + 6 * normalized
    }
}

// MARK: - Card Face Component
/// Single side of the flip card with style support
private struct CardFace: View {
    let mainText: String
    let exampleText: String
    let backgroundColor: Color
    let backgroundGradient: [Color]?
    let cardStyle: CardStyle
    let showSpeakerButton: Bool
    let onSpeakerTap: () -> Void
    let isFront: Bool
    
    var body: some View {
        ZStack {
            // ✅ Background based on style
            RoundedRectangle(cornerRadius: 28)
                .fill(cardBackground)
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                // Main text (word)
                Text(mainText)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                // Example sentence
                if !exampleText.isEmpty {
                    Text(exampleText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(textColor.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // TTS Button
                if showSpeakerButton {
                    Button(action: onSpeakerTap) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 28))
                            .foregroundColor(textColor)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
    
    // MARK: - Style-Based Background
    private var cardBackground: some ShapeStyle {
        switch cardStyle {
        case .colorful:
            // Vertical gradient (original)
            return LinearGradient(
                colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.75)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .minimal:
            // ✅ FIX: Minimal now uses backgroundGradient if available!
            if let gradient = backgroundGradient, gradient.count >= 2 {
                return LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // Fallback
                return LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        case .premium:
            // Premium gradient
            if let gradient = backgroundGradient, gradient.count >= 2 {
                return LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // Fallback
                return LinearGradient(
                    colors: [
                        backgroundColor,
                        backgroundColor.opacity(0.75)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }
    // MARK: - Text Color Based on Style
    private var textColor: Color {
        switch cardStyle {
        case .colorful, .premium, .minimal:
            return .white
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        // Colorful style
        StudyFlipCard(
            card: StudyCard(
                id: UUID(),
                wordId: 1,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            isFlipped: false,
            cardColor: Color(hex: "6366F1"),
            cardGradient: nil,
            cardStyle: .colorful,
            exampleSentence: "Hello, how are you?",
            shouldShowSpeakerOnFront: true,
            isCardFlipped: false,
            onTap: {},
            onSpeakerTap: {}
        )
        .padding()
        
        // Minimal style
        StudyFlipCard(
            card: StudyCard(
                id: UUID(),
                wordId: 2,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            isFlipped: false,
            cardColor: Color(hex: "9CA3AF"),
            cardGradient: nil,
            cardStyle: .minimal,
            exampleSentence: "Hello, how are you?",
            shouldShowSpeakerOnFront: true,
            isCardFlipped: false,
            onTap: {},
            onSpeakerTap: {}
        )
        .padding()
        
        // Premium style
        StudyFlipCard(
            card: StudyCard(
                id: UUID(),
                wordId: 3,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            isFlipped: false,
            cardColor: Color(hex: "667eea"),
            cardGradient: [Color(hex: "667eea"), Color(hex: "764ba2")],
            cardStyle: .premium,
            exampleSentence: "Hello, how are you?",
            shouldShowSpeakerOnFront: true,
            isCardFlipped: false,
            onTap: {},
            onSpeakerTap: {}
        )
        .padding()
    }
}
