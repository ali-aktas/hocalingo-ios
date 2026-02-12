//
//  StudyEmptyStateView.swift
//  HocaLingo
//
//  Empty state view when no words available for study
//  Location: HocaLingo/Features/Study/StudyEmptyStateView.swift
//

import SwiftUI

// MARK: - Study Empty State View
struct StudyEmptyStateView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showPackageSelection = false
    @State private var selectedTabForSheet: Int = 0
    let isFirstTime: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(isFirstTime ? "lingohoca3" : "lingohoca2")
                .resizable()
                .scaledToFit()
                .frame(width: isFirstTime ? 200 : 180, height: isFirstTime ? 200 : 180)
            
            VStack(spacing: 12) {
                Text(isFirstTime ? "Hoş Geldin!" : "Tebrikler!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(isFirstTime
                     ? "Öğrenmeye başlamak için kelime paketlerinden kelime seç."
                     : "Çalışacak kelimen kalmadı! Daha fazla kelime ekleyebilir veya mevcut kelimelerin tekrarını bekleyebilirsin."
                )
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    showPackageSelection = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isFirstTime ? "plus.circle.fill" : "square.grid.2x2.fill")
                            .font(.system(size: 20))
                        
                        Text(isFirstTime ? "Kelime Seç" : "Paketlere Gözat")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
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
                
                Button(action: {
                    selectedTab = 0
                }) {
                    Text("Ana Sayfaya Dön")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
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

