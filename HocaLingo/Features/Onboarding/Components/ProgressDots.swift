//
//  ProgressDots.swift
//  HocaLingo
//
//  ✅ V2: Bounce pulse when a dot transitions from active → completed
//  ✅ V2: Pulse only fires on forward navigation (not on back)
//  Minimal dot progress indicator for onboarding
//  Location: HocaLingo/Features/Onboarding/Components/ProgressDots.swift
//

import SwiftUI

// MARK: - Progress Dots
struct ProgressDots: View {
    let currentStep: Int
    let totalSteps: Int
    
    // ✅ V2: Tracks which dot should play the "just completed" pulse
    @State private var pulsingIndex: Int? = nil

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(dotColor(for: index))
                    .frame(
                        width: index == currentStep ? 24 : 8,
                        height: 8
                    )
                    .scaleEffect(pulsingIndex == index ? 1.4 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
                    .animation(.spring(response: 0.28, dampingFraction: 0.5), value: pulsingIndex)
            }
        }
        // ✅ V2: Pulse the just-completed dot on forward navigation
        .onChange(of: currentStep) { oldValue, newValue in
            guard newValue > oldValue else { return }  // Forward only — no pulse on back
            let completedDot = oldValue
            pulsingIndex = completedDot
            
            // Reset pulse after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if pulsingIndex == completedDot {
                    pulsingIndex = nil
                }
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        if index == currentStep {
            return Color(hex: "4ECDC4")
        } else if index < currentStep {
            return Color(hex: "4ECDC4").opacity(0.4)
        } else {
            return Color.white.opacity(0.15)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "1A1230").ignoresSafeArea()
        VStack(spacing: 24) {
            ProgressDots(currentStep: 0, totalSteps: 5)
            ProgressDots(currentStep: 2, totalSteps: 5)
            ProgressDots(currentStep: 4, totalSteps: 5)
        }
    }
}
