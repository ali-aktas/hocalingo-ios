//
//  HardWordsNudgeBanner.swift
//  HocaLingo
//
//  ✅ NEW: Home screen nudge for the Hard Words Quiz feature.
//  Visible to free users who have accumulated 5+ hard words but haven't tried the quiz.
//  Location: HocaLingo/Features/Home/HardWordsNudgeBanner.swift
//

import SwiftUI

// MARK: - Hard Words Nudge Banner
/// Dismissable horizontal card that promotes the Hard Words Quiz feature.
/// Displayed on HomeView above the vault preview row.
struct HardWordsNudgeBanner: View {
    
    // Current hard-word count — drives the title text and dismissal tracking.
    let hardWordsCount: Int
    
    // Called when the user taps the banner (not the X) — should open the Vault.
    let onTap: () -> Void
    
    // Called when the user taps the X — banner disappears and limit manager records it.
    let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    
    // Fire/flame accent palette (matches the vault flame icon context)
    private let flameStart = Color(hex: "F97316")   // Orange
    private let flameEnd   = Color(hex: "EF4444")   // Red
    private let goldAccent = Color(hex: "FFD700")
    
    private var flameGradient: LinearGradient {
        LinearGradient(colors: [flameStart, flameEnd],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playClickSound()
            onTap()
        }) {
            HStack(spacing: 14) {
                
                // Flame icon with gradient + subtle ring
                ZStack {
                    Circle()
                        .fill(flameGradient.opacity(0.18))
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .stroke(flameGradient, lineWidth: 1.5)
                        .frame(width: 48, height: 48)
                        .opacity(0.55)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(flameGradient)
                }
                
                // Text stack
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(LocalizedStringKey("hard_words_nudge_title"))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        // Live count chip
                        Text("\(hardWordsCount)")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(flameGradient)
                            .clipShape(Capsule())
                    }
                    
                    Text(LocalizedStringKey("hard_words_nudge_subtitle"))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer(minLength: 4)
                
                // Chevron — tap affordance
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(flameEnd.opacity(isDark ? 0.30 : 0.20), lineWidth: 1)
                    )
                    .shadow(color: flameEnd.opacity(isDark ? 0.18 : 0.10), radius: 10, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(alignment: .topTrailing) {
            // Close button — sits ON TOP, outside the main Button
            Button(action: {
                SoundManager.shared.playClickSound()
                onDismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: -6, y: 6)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HardWordsNudgeBanner(
            hardWordsCount: 5,
            onTap: { print("banner tapped") },
            onDismiss: { print("banner dismissed") }
        )
        HardWordsNudgeBanner(
            hardWordsCount: 12,
            onTap: {},
            onDismiss: {}
        )
    }
    .padding()
    .background(Color(hex: "1A1625"))
    .environment(\.themeViewModel, ThemeViewModel.shared)
    .preferredColorScheme(.dark)
}
