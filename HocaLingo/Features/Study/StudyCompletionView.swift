//
//  StudyCompletionView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN: Tab switching instead of navigation
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI

// MARK: - Study Completion View
struct StudyCompletionView: View {
    // ✅ NEW: Tab binding for navigation
    @Binding var selectedTab: Int
    let onContinue: () -> Void
    let onRestart: () -> Void
    
    @State private var animateSuccess = false
    @State private var currentMessageIndex = 0
    
    // Random motivational messages (Android parity)
    private let messages = [
        ("Harika! 🎉", "Bugünlük çalışmanı tamamladın!"),
        ("Mükemmel! ⭐", "Disiplinle devam ediyorsun!"),
        ("Süpersin! 🚀", "Başarıya bir adım daha yaklaştın!"),
        ("Bravo! 💪", "Böyle devam et, harikasın!"),
        ("Tebrikler! 🎯", "Hedeflerine adım adım ilerliyorsun!")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                
                // Success animation
                VStack(spacing: 24) {
                    // Trophy icon with animation
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "FFD700"))
                        .scaleEffect(animateSuccess ? 1.0 : 0.5)
                        .opacity(animateSuccess ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateSuccess)
                    
                    // Random motivational message
                    VStack(spacing: 12) {
                        Text(messages[currentMessageIndex].0)
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.primary)
                        
                        Text(messages[currentMessageIndex].1)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateSuccess ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.4).delay(0.2), value: animateSuccess)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // ✅ FIXED: Action buttons with tab switching
                VStack(spacing: 16) {
                    
                    // Continue button (primary) - Go to Home tab
                    Button(action: {
                        selectedTab = 0  // ✅ Switch to Home tab
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text("Ana Sayfa")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    
                    // Package selection button (secondary) - Go to Home then navigate
                    Button(action: {
                        selectedTab = 0  // ✅ First switch to Home tab
                        // Then trigger navigation to PackageSelection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NotificationCenter.default.post(name: Notification.Name("NavigateToPackageSelection"), object: nil)
                        }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 18))
                            Text("Paket Seç")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "4ECDC4").opacity(0.12))
                        .cornerRadius(14)
                    }
                    
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animateSuccess ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.4).delay(0.4), value: animateSuccess)
                
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Random message selection
            currentMessageIndex = Int.random(in: 0..<messages.count)
            
            // Trigger animations
            withAnimation {
                animateSuccess = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StudyCompletionView(
        selectedTab: .constant(1),
        onContinue: {},
        onRestart: {}
    )
}
