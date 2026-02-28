//
//  OnboardingBackground.swift
//  HocaLingo
//
//  Premium dark background for all onboarding screens
//  Deep purple-navy gradient with animated ambient light blobs
//  Theme-independent: always dark regardless of system setting
//  Location: HocaLingo/Features/Onboarding/Components/OnboardingBackground.swift
//

import SwiftUI

// MARK: - Onboarding Background
struct OnboardingBackground: View {
    /// Each screen can shift the ambient blob position
    var blobOffset: CGPoint = .zero

    @State private var animateBlob = false

    var body: some View {
        ZStack {
            // Base gradient (deep purple-navy)
            LinearGradient(
                colors: [
                    Color(hex: "1A1230"),
                    Color(hex: "0D0B1A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Ambient blob 1 — soft purple glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "6366F1").opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(
                    x: blobOffset.x + (animateBlob ? 20 : -20),
                    y: blobOffset.y + (animateBlob ? -15 : 15)
                )
                .blur(radius: 60)

            // Ambient blob 2 — subtle teal accent
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "4ECDC4").opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(
                    x: -blobOffset.x + (animateBlob ? -30 : 30),
                    y: -blobOffset.y + (animateBlob ? 20 : -20)
                )
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6.0)
                .repeatForever(autoreverses: true)
            ) {
                animateBlob = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingBackground(blobOffset: CGPoint(x: -40, y: -100))
}
