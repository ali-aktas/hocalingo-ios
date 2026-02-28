//
//  GlassCard.swift
//  HocaLingo
//
//  Glassmorphism-style selection card for onboarding
//  Semi-transparent with blur, adapts to selected/unselected state
//  Location: HocaLingo/Features/Onboarding/Components/GlassCard.swift
//

import SwiftUI

// MARK: - Glass Card
struct GlassCard: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(isSelected ? 0.3 : 0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? iconColor : Color.white.opacity(0.6))
                }

                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : Color.white.opacity(0.8))

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.12)
                            : Color.white.opacity(0.06)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial.opacity(0.3))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                            ? Color(hex: "4ECDC4").opacity(0.6)
                            : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(GlassCardButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Glass Card Button Style
private struct GlassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "1A1230").ignoresSafeArea()

        VStack(spacing: 12) {
            GlassCard(
                icon: "flame.fill",
                iconColor: Color(hex: "FF6B6B"),
                title: "Başlayıp bırakıyorum",
                isSelected: true,
                onTap: {}
            )

            GlassCard(
                icon: "brain.head.profile",
                iconColor: Color(hex: "845EF7"),
                title: "Kelimeler aklımda kalmıyor",
                isSelected: false,
                onTap: {}
            )
        }
        .padding()
    }
}
