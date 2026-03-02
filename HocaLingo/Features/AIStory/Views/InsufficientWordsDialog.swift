//
//  InsufficientWordsDialog.swift
//  HocaLingo
//
//  Features/AIStory/Views/InsufficientWordsDialog.swift
//  ✅ REDESIGNED: Modern design, SF Symbols, localized strings
//  Location: HocaLingo/Features/AIStory/Views/InsufficientWordsDialog.swift
//

import SwiftUI

/// Insufficient words dialog - Shown when user doesn't have enough eligible words
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
                headerSection
                contentSection
                buttonsSection
            }
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDarkMode ? Color(hex: "1E1730") : Color.white)
                    .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            )
            .padding(.horizontal, 36)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
            }
            
            // Title
            Text("ai_story_insufficient_title")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 28)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Content
    
    private var contentSection: some View {
        VStack(spacing: 16) {
            // Explanation
            Text("ai_story_insufficient_desc")
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
            
            // Stats row
            HStack(spacing: 0) {
                // Required
                VStack(spacing: 4) {
                    Text("\(required)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.accentPurple)
                    Text("ai_story_required")
                        .font(.system(size: 11))
                        .foregroundColor(.themeSecondary)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.themeDivider)
                    .frame(width: 1, height: 36)
                
                // Available
                VStack(spacing: 4) {
                    Text("\(available)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("ai_story_available")
                        .font(.system(size: 11))
                        .foregroundColor(.themeSecondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.themeCardSecondary)
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Buttons
    
    private var buttonsSection: some View {
        VStack(spacing: 10) {
            // Add Words button (primary)
            Button(action: onAddWords) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    Text("ai_story_add_words")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Close button (secondary)
            Button(action: onDismiss) {
                Text("ai_story_close")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.themeSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Preview

#Preview {
    InsufficientWordsDialog(
        required: 20,
        available: 8,
        onDismiss: {},
        onAddWords: {}
    )
}
