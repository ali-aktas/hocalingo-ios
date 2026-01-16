//
//  StudyCompletionView.swift
//  HocaLingo
//
//  ✅ UPDATED: "Yeni Kelimeler Ekle" button navigates to PackageSelection
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI

// MARK: - Study Completion View
/// Shown when user finishes all cards in study session
struct StudyCompletionView: View {
    let onContinue: () -> Void
    let onRestart: () -> Void
    
    @State private var showPackageSelection = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 16)
            
            // Title
            Text("Harika!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            // Subtitle
            Text("Bugünlük çalışmanı tamamladın!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                // ✅ FIX 2: "Yeni Kelimeler Ekle" button
                Button(action: {
                    showPackageSelection = true
                }) {
                    Text("Yeni Kelimeler Ekle")
                        .font(.system(size: 18, weight: .semibold))
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
                
                // Continue to Home Button
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
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView()
        }
    }
}

// MARK: - Preview
#Preview {
    StudyCompletionView(
        onContinue: {},
        onRestart: {}
    )
}
