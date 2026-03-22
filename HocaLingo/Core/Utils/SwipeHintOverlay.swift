//
//  SwipeHintOverlay.swift
//  HocaLingo
//
//  ✅ NEW: Reusable first-time hint overlay with Lottie swipe animation
//  Shows once per screen (tracked via UserDefaults key)
//  Auto-dismisses after 3.5 seconds or on tap
//  Location: Core/Utils/SwipeHintOverlay.swift
//

import SwiftUI
import Lottie

// MARK: - Swipe Hint Overlay
/// Reusable overlay that shows a Lottie swipe hint animation with instruction text.
/// Displays only once per `userDefaultsKey`, then never again.
/// Usage:
/// ```
/// SwipeHintOverlay(
///     hintTextKey: "swipe_hint_word_selection",
///     userDefaultsKey: "has_seen_ws_hint",
///     isVisible: $showHint
/// )
/// ```
struct SwipeHintOverlay: View {
    
    // MARK: - Properties
    let hintTextKey: String        // Localizable.strings key for instruction text
    let userDefaultsKey: String    // UserDefaults flag to track "shown once"
    @Binding var isVisible: Bool
    
    // MARK: - State
    @State private var overlayOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.85
    
    // MARK: - Body
    var body: some View {
        if isVisible {
            ZStack {
                // Semi-transparent backdrop
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissHint()
                    }
                
                // Centered content
                VStack(spacing: 24) {
                    // Lottie swipe animation
                    LottieView(
                        animationName: "swipe_hint",
                        loopMode: .loop,
                        animationSpeed: 0.8
                    )
                    .frame(width: 180, height: 180)
                    
                    // Instruction text
                    Text(L(hintTextKey))
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                    
                    // Dismiss hint
                    Text(L("hint_tap_to_dismiss"))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.top, 4)
                }
                .scaleEffect(contentScale)
            }
            .opacity(overlayOpacity)
            .onAppear {
                // Animate in
                withAnimation(.easeOut(duration: 0.3)) {
                    overlayOpacity = 1
                    contentScale = 1.0
                }
                // Auto-dismiss after 3.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    dismissHint()
                }
            }
        }
    }
    
    // MARK: - Dismiss
    private func dismissHint() {
        guard isVisible else { return }
        
        withAnimation(.easeIn(duration: 0.2)) {
            overlayOpacity = 0
            contentScale = 0.9
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isVisible = false
            UserDefaults.standard.set(true, forKey: userDefaultsKey)
        }
    }
}

// MARK: - Convenience: Check & Show
/// Call this to conditionally trigger the hint overlay
/// Returns true if the hint should be shown (never shown before)
func shouldShowHint(for key: String) -> Bool {
    return !UserDefaults.standard.bool(forKey: key)
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.blue.opacity(0.3).ignoresSafeArea()
        SwipeHintOverlay(
            hintTextKey: "swipe_hint_word_selection",
            userDefaultsKey: "preview_hint",
            isVisible: .constant(true)
        )
    }
}
