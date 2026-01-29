//
//  OnboardingButton.swift
//  HocaLingo
//
//  ✅ FIXED: Localization support (LocalizedStringKey)
//  Location: HocaLingo/Features/Onboarding/Components/OnboardingButton.swift
//

import SwiftUI

// MARK: - Onboarding Button
struct OnboardingButton: View {
    let title: LocalizedStringKey  // ✅ FIXED: String → LocalizedStringKey
    let isEnabled: Bool
    let action: () -> Void
    
    init(title: LocalizedStringKey, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                // Haptic feedback
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? Color(hex: "4ECDC4") : Color.gray.opacity(0.3))
                )
                .shadow(
                    color: isEnabled ? Color(hex: "4ECDC4").opacity(0.3) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .disabled(!isEnabled)
        .animation(.spring(response: 0.3), value: isEnabled)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        OnboardingButton(title: "onboarding_button_next", isEnabled: true) {
            print("Button tapped")
        }
        
        OnboardingButton(title: "onboarding_button_next", isEnabled: false) {
            print("Button tapped")
        }
    }
    .padding()
}
