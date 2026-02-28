//
//  OnboardingButton.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Premium button with glow for dark onboarding background
//  Location: HocaLingo/Features/Onboarding/Components/OnboardingButton.swift
//

import SwiftUI

// MARK: - Onboarding Button
struct OnboardingButton: View {
    let title: LocalizedStringKey
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(isEnabled ? Color(hex: "0D0B1A") : Color.white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isEnabled
                                ? Color(hex: "4ECDC4")
                                : Color.white.opacity(0.08)
                        )
                )
                .shadow(
                    color: isEnabled ? Color(hex: "4ECDC4").opacity(0.4) : .clear,
                    radius: 16,
                    x: 0,
                    y: 8
                )
        }
        .disabled(!isEnabled)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "1A1230").ignoresSafeArea()
        VStack(spacing: 16) {
            OnboardingButton(title: "Başla", isEnabled: true) {}
            OnboardingButton(title: "Devam", isEnabled: false) {}
        }
        .padding()
    }
}
