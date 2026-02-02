//
//  GeneratingView.swift
//  HocaLingo
//
//  Features/AIStory/Views/GeneratingView.swift
//  Premium glow animation overlay
//

import SwiftUI
import Combine

/// Generating overlay with premium glow animation
struct GeneratingView: View {
    
    @ObservedObject var viewModel: AIStoryViewModel
    @State private var rotation: Double = 0
    @State private var glowIntensity: Double = 0.8
    @State private var dotCount: Int = 0
    
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Rotating glow circle
                glowCircle
                
                // Phase icon and text
                phaseContent
                
                // Animated dots
                animatedDots
            }
        }
        .onAppear {
            startAnimations()
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
    
    // MARK: - Components
    
    private var glowCircle: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "6366F1").opacity(glowIntensity),
                            Color(hex: "8B5CF6").opacity(glowIntensity * 0.6),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .rotationEffect(.degrees(rotation))
            
            // Inner circle
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
                .frame(width: 120, height: 120)
                .shadow(color: Color(hex: "6366F1").opacity(0.6), radius: 20, y: 10)
            
            // Phase icon
            Image(systemName: currentPhase.icon)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var phaseContent: some View {
        VStack(spacing: 12) {
            Text(LocalizedStringKey(currentPhase.title))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Lütfen bekleyin")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
        }
    }
    
    private var animatedDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(index <= dotCount ? 0.8 : 0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: dotCount)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentPhase: GeneratingPhase {
        viewModel.uiState.generatingPhase
    }
    
    private func startAnimations() {
        // Rotation animation
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 1.2
        }
    }
}
