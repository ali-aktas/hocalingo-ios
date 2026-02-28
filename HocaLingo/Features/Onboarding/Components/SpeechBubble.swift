//
//  SpeechBubble.swift
//  HocaLingo
//
//  Mascot speech bubble with pop-in animation
//  Shows contextual messages from the Hoca character
//  Location: HocaLingo/Features/Onboarding/Components/SpeechBubble.swift
//

import SwiftUI

// MARK: - Speech Bubble
struct SpeechBubble: View {
    let message: LocalizedStringKey

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 0) {
            // Bubble tail (left pointing triangle)
            Triangle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 12, height: 16)
                .rotationEffect(.degrees(-90))
                .offset(x: 4)

            // Bubble body
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
        .scaleEffect(appeared ? 1 : 0.3)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Triangle Shape
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "1A1230").ignoresSafeArea()
        SpeechBubble(message: "Tam senlik bir sistem var.")
    }
}
