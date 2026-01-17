//
//  StudyCompletionView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN: Rich completion screen - Android parity
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI

// MARK: - Study Completion View
/// Rich completion screen shown when user finishes all cards
struct StudyCompletionView: View {
    let onContinue: () -> Void
    let onRestart: () -> Void
    
    @State private var showPackageSelection = false
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
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success icon with animation
                successIcon
                
                // Title & Subtitle
                VStack(spacing: 12) {
                    Text(currentMessage.0)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(currentMessage.1)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Stats cards (Android parity)
                statsSection
                
                Spacer()
                
                // Action buttons
                actionButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateSuccess = true
            }
            // Random message
            currentMessageIndex = Int.random(in: 0..<messages.count)
        }
    }
    
    // MARK: - Success Icon
    private var successIcon: some View {
        ZStack {
            // Outer glow circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "4ECDC4").opacity(0.3),
                            Color(hex: "4ECDC4").opacity(0)
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .opacity(animateSuccess ? 1 : 0)
                .scaleEffect(animateSuccess ? 1 : 0.5)
            
            // Main circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: Color(hex: "4ECDC4").opacity(0.4), radius: 20, x: 0, y: 10)
                .scaleEffect(animateSuccess ? 1 : 0.3)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(animateSuccess ? 1 : 0)
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(UserDefaultsManager.shared.loadUserStats().currentStreak)",
                    label: "Günlük Seri",
                    color: Color(hex: "EF4444")
                )
                
                StatCard(
                    icon: "clock.fill",
                    value: timeStudiedToday,
                    label: "Bugün",
                    color: Color(hex: "F97316")
                )
            }
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "star.fill",
                    value: "0",
                    label: "Disiplin",
                    color: Color(hex: "10B981")
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(UserDefaultsManager.shared.getTodayDailyStats().wordsGraduated)",
                    label: "Öğrenilen",
                    color: Color(hex: "8B5CF6")
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Add words button
            Button(action: {
                showPackageSelection = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Yeni Kelimeler Ekle")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            // Home button
            Button(action: onContinue) {
                Text("Ana Sayfaya Dön")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "4ECDC4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "4ECDC4").opacity(0.1))
                    .cornerRadius(16)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var currentMessage: (String, String) {
        messages[currentMessageIndex]
    }
    
    private var timeStudiedToday: String {
        let minutes = UserDefaultsManager.shared.getTodayDailyStats().wordsStudied * 2  // Rough estimate
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            // Label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    StudyCompletionView(
        onContinue: {},
        onRestart: {}
    )
}
