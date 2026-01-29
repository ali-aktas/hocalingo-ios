//
//  ProgressIndicator.swift
//  HocaLingo
//
//  Onboarding progress indicator - Clean minimal design
//  Location: HocaLingo/Features/Onboarding/Components/ProgressIndicator.swift
//

import SwiftUI

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    // Active progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "4ECDC4"))
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 4)
            
            // Step counter text
            HStack {
                Spacer()
                Text("\(currentStep) / \(totalSteps)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var progress: CGFloat {
        return CGFloat(currentStep) / CGFloat(totalSteps)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 32) {
        ProgressIndicator(currentStep: 1, totalSteps: 4)
        ProgressIndicator(currentStep: 2, totalSteps: 4)
        ProgressIndicator(currentStep: 3, totalSteps: 4)
        ProgressIndicator(currentStep: 4, totalSteps: 4)
    }
    .padding()
}
