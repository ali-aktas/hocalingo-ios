//
//  StudyFlipCard.swift
//  HocaLingo
//
//  ✅ NEW: Perfect 3D flip animation - Android parity (StudyComponents.kt)
//  Location: HocaLingo/Features/Study/StudyFlipCard.swift
//

import SwiftUI

// MARK: - Study Flip Card
/// Premium 3D flip card with perfect animation matching Android exactly
///
/// Features:
/// - Smooth 3D rotation with dynamic elevation
/// - No "edge glitch" at 90° (Android parity)
/// - TTS button support
/// - Example sentences
/// - Vibrant gradient background
struct StudyFlipCard: View {
    
    // MARK: - Properties
    let card: StudyCard
    let isFlipped: Bool
    let cardColor: Color
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
            // ✅ ANDROID PARITY: 3D depth shadow (tablet effect)
            depthShadow
            
            // ✅ Main card with perfect flip
            mainCard
        }
        .onChange(of: isFlipped) { _, newValue in
            // ✅ ANDROID PARITY: Spring animation (dampingRatio: 0.85, stiffness: 280)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                rotation = newValue ? 180 : 0
            }
        }
        .onAppear {
            rotation = isFlipped ? 180 : 0
        }
    }
    
    // MARK: - Depth Shadow (3D Effect)
    /// Creates the illusion of card thickness - Android parity
    private var depthShadow: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(Color.black.opacity(0.18))
            .frame(maxWidth: .infinity)
            .aspectRatio(0.7, contentMode: .fit)
            .offset(y: 8)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3  // ✅ ANDROID: cameraDistance = 32f * density
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
                showSpeakerButton: !shouldShowSpeakerOnFront && isCardFlipped,
                onSpeakerTap: onSpeakerTap,
                isFront: false
            )
            .opacity(rotation > 90 ? 1 : 0)  // ✅ FIX: Smooth transition
            .rotation3DEffect(
                .degrees(rotation - 180),  // ✅ Correct back rotation
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            
            // Front side (default state)
            CardFace(
                mainText: card.frontText,
                exampleText: exampleSentence,
                backgroundColor: cardColor,
                showSpeakerButton: shouldShowSpeakerOnFront && !isCardFlipped,
                onSpeakerTap: onSpeakerTap,
                isFront: true
            )
            .opacity(rotation <= 90 ? 1 : 0)  // ✅ FIX: Smooth transition
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.7, contentMode: .fit)
        .shadow(
            color: cardColor.opacity(dynamicShadowOpacity),
            radius: dynamicShadowRadius,
            x: 0,
            y: dynamicShadowOffset
        )
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Dynamic Shadow (Android Parity)
    /// Shadow that changes based on rotation angle - creates 3D illusion
    private var dynamicShadowOpacity: Double {
        // Maximum shadow at 90° (card edge), minimum at 0°/180°
        let normalized = abs(rotation - 90) / 90
        return 0.3 * (1 - normalized) + 0.15 * normalized
    }
    
    private var dynamicShadowRadius: CGFloat {
        // Maximum radius at 90°
        let normalized = abs(rotation - 90) / 90
        return 18 * (1 - normalized) + 8 * normalized
    }
    
    private var dynamicShadowOffset: CGFloat {
        // Maximum offset at 90°
        let normalized = abs(rotation - 90) / 90
        return 12 * (1 - normalized) + 6 * normalized
    }
}

// MARK: - Card Face Component
/// Single side of the flip card
private struct CardFace: View {
    let mainText: String
    let exampleText: String
    let backgroundColor: Color
    let showSpeakerButton: Bool
    let onSpeakerTap: () -> Void
    let isFront: Bool
    
    var body: some View {
        ZStack {
            // ✅ ANDROID PARITY: Vertical gradient background
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            backgroundColor,
                            backgroundColor.opacity(0.75)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                // Main text (word)
                Text(mainText)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                // Example sentence
                if !exampleText.isEmpty {
                    Text(exampleText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // TTS Button
                if showSpeakerButton {
                    Button(action: onSpeakerTap) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        // Front
        StudyFlipCard(
            card: StudyCard(
                id: UUID(),
                wordId: 1,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            isFlipped: false,
            cardColor: Color(hex: "6366F1"),
            exampleSentence: "Hello, how are you?",
            shouldShowSpeakerOnFront: true,
            isCardFlipped: false,
            onTap: {},
            onSpeakerTap: {}
        )
        .padding()
        
        // Back
        StudyFlipCard(
            card: StudyCard(
                id: UUID(),
                wordId: 1,
                frontText: "Hello",
                backText: "Merhaba"
            ),
            isFlipped: true,
            cardColor: Color(hex: "EC4899"),
            exampleSentence: "Merhaba, nasılsın?",
            shouldShowSpeakerOnFront: true,
            isCardFlipped: true,
            onTap: {},
            onSpeakerTap: {}
        )
        .padding()
    }
}
