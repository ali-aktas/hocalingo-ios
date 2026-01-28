//
//  StudyCompletionView.swift
//  HocaLingo
//
//  Study session completion screen with motivational messages
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI

// MARK: - Study Completion View
struct StudyCompletionView: View {
    @Binding var selectedTab: Int
    let onContinue: () -> Void
    let onRestart: () -> Void
    
    @State private var showPackageSelection = false
    @State private var selectedTabForSheet: Int = 0
    @State private var animateSuccess = false
    @State private var currentMessageIndex = 0
    
    private let messages = [
        ("Harika! 🎉", "Bugünlük çalışmanı tamamladın!"),
        ("Mükemmel! ⭐", "Disiplinle devam ediyorsun!"),
        ("Süpersin! 🚀", "Başarıya bir adım daha yaklaştın!"),
        ("Bravo! 💪", "Böyle devam et, harikasın!"),
        ("Tebrikler! 🎯", "Hedeflerine adım adım ilerliyorsun!")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "FFD700"))
                        .scaleEffect(animateSuccess ? 1.0 : 0.5)
                        .opacity(animateSuccess ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateSuccess)
                    
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
                
                VStack(spacing: 16) {
                    Button(action: {
                        selectedTab = 0
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
                    
                    Button(action: {
                        showPackageSelection = true
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
            currentMessageIndex = Int.random(in: 0..<messages.count)
            withAnimation {
                animateSuccess = true
            }
        }
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView(selectedTab: $selectedTabForSheet)
                .onDisappear {
                    if selectedTabForSheet == 1 {
                        selectedTab = 1
                    }
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
