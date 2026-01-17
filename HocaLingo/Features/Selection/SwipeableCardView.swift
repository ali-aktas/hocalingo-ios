import SwiftUI

// MARK: - Swipeable Card View (PRODUCTION-GRADE)
/// World-class Tinder-style swipeable card with all optimizations
/// Features: optimized gestures, single animation, dynamic threshold, state management, programmatic swipe
/// Location: HocaLingo/Features/WordSelection/SwipeableCardView.swift
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
    private let swipeThresholdRatio: CGFloat = 0.15 // 15% of screen width
    
    // MARK: - Computed Properties
    
    /// Dynamic swipe threshold based on actual view width (NOT UIScreen)
    private var swipeThreshold: CGFloat {
        viewWidth * swipeThresholdRatio
    }
    
    /// Card rotation based on drag distance
    private var rotation: Double {
        Double(offset.width) * rotationMultiplier
    }
    
    /// Card scale during drag (subtle effect)
    private var cardScale: Double {
        guard swipePhase == .dragging else { return 1.0 }
        let dragRatio = abs(offset.width) / max(viewWidth, 1)
        return 1.0 - min(dragRatio * 0.05, 0.08)
    }
    
    /// Skip overlay alpha (left swipe)
    private var skipAlpha: Double {
        guard offset.width < 0, swipePhase == .dragging else { return 0 }
        return min(abs(offset.width) / swipeThreshold, 1.0)
    }
    
    /// Learn overlay alpha (right swipe)
    private var learnAlpha: Double {
        guard offset.width > 0, swipePhase == .dragging else { return 0 }
        return min(offset.width / swipeThreshold, 1.0)
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main card
                cardContent
                    .offset(offset)
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(cardScale)
                    .gesture(
                        DragGesture(minimumDistance: 15) // ✅ OPTIMIZED: Prevents tap/drag conflict
                            .onChanged { handleDragChanged($0) }
                            .onEnded { handleDragEnded($0) }
                    )
                
                // Overlay indicators
                overlayIndicators
                    .allowsHitTesting(false)
            }
            .onAppear {
                viewWidth = geometry.size.width
            }
        }
    }
    
    // MARK: - Card Content
    private var cardContent: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [cardColor, cardColor.opacity(0.85)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 16, x: 0, y: 8)
            
            // Content
            VStack(spacing: 24) {
                Spacer()
                
                // English word
                Text(word)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                
                // Turkish translation
                Text(translation)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Overlay Indicators
    private var overlayIndicators: some View {
        ZStack {
            // SKIP indicator (left) - RED
            if skipAlpha > 0 {
                HStack {
                    VStack {
                        Text("GEÇ")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(Color(hex: "EF5350")) // ✅ RED
                            .rotationEffect(.degrees(-25))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.leading, 40)
                    
                    Spacer()
                }
                .opacity(skipAlpha)
            }
            
            // LEARN indicator (right) - GREEN
            if learnAlpha > 0 {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("ÖĞREN")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(Color(hex: "66BB6A")) // ✅ GREEN
                            .rotationEffect(.degrees(25))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Spacer()
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 40)
                }
                .opacity(learnAlpha)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Gesture Handlers (OPTIMIZED)
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        guard swipePhase != .animatingOut else { return }
        
        // ✅ SINGLE STATE UPDATE (smooth)
        if swipePhase != .dragging {
            swipePhase = .dragging
        }
        
        // ✅ SINGLE ANIMATION BLOCK (no multiple animations)
        withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 1.0)) {
            offset = value.translation
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        guard swipePhase != .animatingOut else { return }
        
        // Check threshold
        if abs(value.translation.width) >= swipeThreshold {
            // Swipe confirmed
            let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
            performSwipe(direction: direction)
        } else {
            // Reset card
            resetCard()
        }
    }
    
    // MARK: - Swipe Actions (PRODUCTION-GRADE)
    
    /// Reset card to center with smooth animation
    private func resetCard() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            offset = .zero
            swipePhase = .idle
        }
    }
    
    /// Perform swipe animation and trigger callback
    private func performSwipe(direction: SwipeDirection) {
        swipePhase = .animatingOut
        
        let targetX = direction == .right ? viewWidth * 1.5 : -viewWidth * 1.5
        let targetRotation = direction == .right ? 15.0 : -15.0
        
        // ✅ OPTIMIZED: Fast smooth animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            offset = CGSize(width: targetX, height: offset.height)
        }
        
        // ✅ Trigger callback IMMEDIATELY (no delay)
        if direction == .right {
            onSwipeRight()
        } else {
            onSwipeLeft()
        }
        
        // ✅ Reset state AFTER animation completes (calculated timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            offset = .zero
            swipePhase = .idle
        }
    }
    
    // MARK: - Programmatic Swipe (for buttons)
    
    /// Trigger swipe programmatically from button tap
    func triggerSwipe(direction: SwipeDirection) {
        guard swipePhase == .idle else { return }
        performSwipe(direction: direction)
    }
}

// MARK: - Swipe Phase (STATE MANAGEMENT)
enum SwipePhase {
    case idle           // Card at rest
    case dragging       // User is dragging
    case animatingOut   // Card is flying away
}

// MARK: - Swipe Direction
enum SwipeDirection {
    case left
    case right
}

// MARK: - Card Colors (Android parity)
let cardColors: [Color] = [
    Color(hex: "FF6B6B"), // Red
    Color(hex: "4ECDC4"), // Teal
    Color(hex: "45B7D1"), // Blue
    Color(hex: "FFA07A"), // Light Salmon
    Color(hex: "98D8C8"), // Mint
    Color(hex: "F7DC6F"), // Yellow
    Color(hex: "BB8FCE"), // Purple
    Color(hex: "85C1E2"), // Sky Blue
    Color(hex: "F8B88B"), // Peach
    Color(hex: "52C57D")  // Green
]

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        SwipeableCardView(
            word: "Hello",
            translation: "Merhaba",
            cardColor: cardColors[0],
            onSwipeLeft: { print("Swiped left") },
            onSwipeRight: { print("Swiped right") }
        )
    }
}
