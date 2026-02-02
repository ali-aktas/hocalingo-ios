//
//  InsufficientWordsDialog.swift
//  HocaLingo
//
//  Features/AIStory/Views/InsufficientWordsDialog.swift
//  AI-themed dialog for insufficient eligible words warning
//

import SwiftUI

/// Insufficient words dialog - Shown when user doesn't have enough words (progress < 21 days)
struct InsufficientWordsDialog: View {
    
    let required: Int
    let available: Int
    let onDismiss: () -> Void
    let onAddWords: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Dialog card
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                contentSection
                
                // Buttons
                buttonsSection
            }
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isDarkMode ? Color(hex: "1F1B2E") : Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
            }
            
            // Title
            Text("Not Enough Active Words")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Content
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            // Explanation
            Text("AI needs words you're actively learning (progress < 21 days) to create a story.")
                .font(.system(size: 15))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            // Stats box
            HStack(spacing: 0) {
                // Available
                VStack(spacing: 6) {
                    Text("\(available)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text("Available")
                        .font(.system(size: 13))
                        .foregroundColor(.themeSecondary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.themeSecondary.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                // Required
                VStack(spacing: 6) {
                    Text("\(required)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.accentPurple)
                    
                    Text("Required")
                        .font(.system(size: 13))
                        .foregroundColor(.themeSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDarkMode ? Color(hex: "2A2438") : Color(hex: "F5F5F5"))
            )
            
            // Tip
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.accentPurple)
                
                Text("Add more words to your deck and start studying!")
                    .font(.system(size: 14))
                    .foregroundColor(.themeSecondary)
                    .lineSpacing(3)
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentPurple.opacity(0.1))
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }
    
    // MARK: - Buttons
    
    private var buttonsSection: some View {
        VStack(spacing: 12) {
            // Primary: Add Words
            Button {
                onAddWords()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    
                    Text("Add More Words")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
            }
            
            // Secondary: Dismiss
            Button {
                onDismiss()
            } label: {
                Text("Maybe Later")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.themeSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        InsufficientWordsDialog(
            required: 15,
            available: 8,
            onDismiss: {},
            onAddWords: {}
        )
    }
    .environmentObject(ThemeViewModel())
}
