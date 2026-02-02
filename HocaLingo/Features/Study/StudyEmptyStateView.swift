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
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))
            }
            
            VStack(spacing: 12) {
                Text("Henüz Kelime Yok")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Çalışmaya başlamak için kelime paketlerinden kelime seçmelisin.")
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
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                        
                        Text("Kelime Seç")
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

// MARK: - Preview
#Preview {
    StudyEmptyStateView(selectedTab: .constant(1))
}
