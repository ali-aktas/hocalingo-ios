//
//  ProgressDots.swift
//  HocaLingo
//
//  Minimal dot progress indicator for onboarding
//  Active dot is larger and teal, inactive dots are small and dim
//  Location: HocaLingo/Features/Onboarding/Components/ProgressDots.swift
//

import SwiftUI

// MARK: - Progress Dots
struct ProgressDots: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(dotColor(for: index))
                    .frame(
                        width: index == currentStep ? 24 : 8,
                        height: 8
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: currentStep)
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
