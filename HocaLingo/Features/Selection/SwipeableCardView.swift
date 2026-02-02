//
//  SwipeableCardView.swift
//  HocaLingo
//
//  ✅ UPDATED: Green LEARN, Red SKIP overlays matching button colors
//  Location: HocaLingo/Features/Selection/SwipeableCardView.swift
//

import SwiftUI

// MARK: - Swipeable Card View
struct SwipeableCardView: View {
    // MARK: - Properties
    let word: String
    let translation: String
    let cardColor: Color
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    // MARK: - State
    @State private var offset: CGSize = .zero
    @State private var swipePhase: SwipePhase = .idle
    @State private var viewWidth: CGFloat = 0
    
    // MARK: - Constants
    private let rotationMultiplier: Double = 0.025
    private let swipeThresholdRatio: CGFloat = 0.20
    private let animationDuration: Double = 0.35
    
    // ✅ Button colors (matching action buttons)
    private let skipColor = Color(hex: "EF5350") // Red
    private let learnColor = Color(hex: "66BB6A") // Green
    
    // MARK: - Computed Properties
    
    private var swipeThreshold: CGFloat {
        viewWidth * swipeThresholdRatio
    }
    
    private var rotation: Double {
        Double(offset.width) * rotationMultiplier
    }
    
    private var cardScale: Double {
        guard swipePhase == .dragging else { return 1.0 }
        let dragRatio = abs(offset.width) / max(viewWidth, 1)
        return 1.0 - min(dragRatio * 0.05, 0.08)
    }
    
    private var skipAlpha: Double {
        guard offset.width < 0, swipePhase == .dragging else { return 0 }
        return min(abs(offset.width) / swipeThreshold, 1.0)
    }
    
    private var learnAlpha: Double {
        guard offset.width > 0, swipePhase == .dragging else { return 0 }
        return min(offset.width / swipeThreshold, 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main card
                cardContent
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(cardColor)
                    .cornerRadius(24)
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 12,
                        x: 0,
                        y: offset == .zero ? 8 : 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                // Skip overlay (left) - RED
                if skipAlpha > 0 {
                    skipOverlay
                        .opacity(skipAlpha)
                }
                
                // Learn overlay (right) - GREEN
                if learnAlpha > 0 {
                    learnOverlay
                        .opacity(learnAlpha)
                }
            }
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(cardScale)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if swipePhase == .idle {
                            swipePhase = .dragging
                        }
                        offset = gesture.translation
                    }
                    .onEnded { gesture in
                        handleSwipeEnd(translation: gesture.translation)
                    }
            )
            .onAppear {
                viewWidth = geometry.size.width
            }
        }
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // English word
            Text(word)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: 200)
            
            // Turkish translation
            Text(translation)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
    }
    
    // MARK: - Skip Overlay (RED)
    /// ✅ Updated: Red color matching skip button
    private var skipOverlay: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(skipColor) // ✅ Red
                    
                    Text("SKIP")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(skipColor) // ✅ Red
                }
                .padding(.trailing, 32)
                .padding(.top, 40)
                
                Spacer()
            }
            Spacer()
        }
        .background(skipColor.opacity(0.15)) // ✅ Light red background
        .cornerRadius(24)
    }
    
    // MARK: - Learn Overlay (GREEN)
    /// ✅ Updated: Green color matching learn button
    private var learnOverlay: some View {
        VStack {
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundColor(learnColor) // ✅ Green
                    
                    Text("LEARN")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(learnColor) // ✅ Green
                }
                .padding(.leading, 32)
                .padding(.top, 40)
                
                Spacer()
            }
            Spacer()
        }
        .background(learnColor.opacity(0.15)) // ✅ Light green background
        .cornerRadius(24)
    }
    
    // MARK: - Handle Swipe End
    private func handleSwipeEnd(translation: CGSize) {
        let horizontalMovement = translation.width
        
        if abs(horizontalMovement) > swipeThreshold {
            let swipeDirection: SwipeDirection = horizontalMovement > 0 ? .right : .left
            
            let finalOffset = CGSize(
                width: horizontalMovement > 0 ? viewWidth * 1.5 : -viewWidth * 1.5,
                height: translation.height
            )
            
            withAnimation(.easeOut(duration: animationDuration)) {
                offset = finalOffset
                swipePhase = .completing
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                if swipeDirection == .left {
                    onSwipeLeft()
                } else {
                    onSwipeRight()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    offset = .zero
                    swipePhase = .idle
                }
            }
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offset = .zero
                swipePhase = .idle
            }
        }
    }
}

// MARK: - Swipe Phase
private enum SwipePhase {
    case idle
    case dragging
    case completing
}

// MARK: - Swipe Direction
private enum SwipeDirection {
    case left
    case right
}

// MARK: - Preview
struct SwipeableCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            
            SwipeableCardView(
                word: "Hello",
                translation: "Merhaba",
                cardColor: Color(hex: "5C6BC0"),
                onSwipeLeft: { print("Swiped left") },
                onSwipeRight: { print("Swiped right") }
            )
            .frame(height: 500)
            .padding(.horizontal, 20)
        }
    }
}
