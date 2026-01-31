//
//  AIStoryMainView.swift
//  HocaLingo
//
//  Features/AIStory/AIStoryMainView.swift
//  AI Story Generation - Main Screen (BASIC VERSION FOR TESTING)
//  Full version will be implemented in Phase 3
//

import SwiftUI

/// AI Story Main Screen - Basic test version
/// Shows quota, create button, and placeholder for stories
struct AIStoryMainView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeViewModel: ThemeViewModel
    
    // Test data
    @State private var quotaUsed = 0
    @State private var quotaTotal = 3
    @State private var isPremium = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hex: "1A1625"),
                    Color(hex: "211A2E")
                ] : [
                    Color(hex: "FBF2FF"),
                    Color(hex: "FAF1FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Quota Card
                    quotaCard
                    
                    // History Card
                    historyCard
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Floating Create Button
            VStack {
                Spacer()
                createButton
                    .padding(.bottom, 40)
            }
        }
        .navigationTitle("AI Hikaye Asistanı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🤖")
                .font(.system(size: 64))
            
            Text("AI Hikaye Asistanı")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Yapay zeka ile öğrendiğin kelimelerden hikayeler oluştur")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var quotaCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("Kalan Hak")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(quotaTotal - quotaUsed)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
                
                Text("/ \(quotaTotal)")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(isPremium ? "Premium - 30 hikaye/ay" : "Free - 3 hikaye/ay")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDarkMode ? Color(hex: "2A2438") : .white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.orange)
                Text("Geçmiş Hikayeler")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            Text("Henüz hikaye oluşturmadınız")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDarkMode ? Color(hex: "2A2438") : .white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    private var createButton: some View {
        Button {
            // TODO: Open creator dialog
            print("🎨 Create story tapped")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Hikaye Oluştur")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.purple.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 20)
        .disabled(quotaUsed >= quotaTotal)
    }
    
    // MARK: - Helpers
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AIStoryMainView()
            .environmentObject(ThemeViewModel())
    }
}
