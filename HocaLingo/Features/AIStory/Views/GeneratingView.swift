//
//  GeneratingView.swift
//  HocaLingo
//
//  Features/AIStory/Views/GeneratingView.swift
//  ✅ REDESIGNED: Lottie animation, cleaner design, SF Symbols
//  Location: HocaLingo/Features/AIStory/Views/GeneratingView.swift
//

import SwiftUI
import Lottie
import Combine

/// Generating overlay with Lottie animation
struct GeneratingView: View {
    
    @ObservedObject var viewModel: AIStoryViewModel
    @State private var dotCount: Int = 0
    @State private var pulseScale: CGFloat = 1.0
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 36) {
                // Lottie animation circle
                animationSection
                
                // Phase content
                phaseContent
                
                // Animated dots
                animatedDots
            }
        }
        .onAppear {
            startPulse()
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
    
    // MARK: - Animation Section
    
    private var animationSection: some View {
        ZStack {
            // Lottie sparkle ambient
            LottieView(
                animationName: "sparkle_ambient",
                loopMode: .loop,
                animationSpeed: 0.6
            )
            .frame(width: 260, height: 260)
            .opacity(0.7)
            
            // Inner gradient circle with pulse
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "6366F1"),
                            Color(hex: "8B5CF6")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color(hex: "6366F1").opacity(0.5), radius: 20)
                .scaleEffect(pulseScale)
            
            // Phase icon
            Image(systemName: viewModel.uiState.generatingPhase.icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
                .scaleEffect(pulseScale)
        }
    }
    
    // MARK: - Phase Content
    
    private var phaseContent: some View {
        VStack(spacing: 10) {
            Text(LocalizedStringKey(viewModel.uiState.generatingPhase.title))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .animation(.easeInOut, value: viewModel.uiState.generatingPhase)
            
            Text("ai_story_generating_wait")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    // MARK: - Animated Dots
    
    private var animatedDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "6366F1"))
                    .frame(width: 8, height: 8)
                    .opacity(index < dotCount ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 0.3), value: dotCount)
            }
        }
    }
    
    // MARK: - Pulse Animation
    
    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale = 1.08
        }
    }
}

// MARK: - Preview

#Preview {
    GeneratingView(viewModel: AIStoryViewModel())
}
