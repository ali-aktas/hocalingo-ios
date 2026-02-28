//
//  CompactSelectorRow.swift
//  HocaLingo
//
//  Compact settings row with inline pill-style option buttons
//  Used for: Study Direction, Theme Mode, App Language
//  Location: Features/Profile/Components/CompactSelectorRow.swift
//

import SwiftUI

// MARK: - Compact Selector Row
/// Displays a settings row with icon, title, and inline segmented buttons
/// Replaces the expandable InlineSelection card with always-visible compact controls
struct CompactSelectorRow: View {
    
    let icon: String
    let iconGradient: LinearGradient
    let accentColor: Color
    let titleKey: String
    let options: [SelectionOption]         // Reuses existing SelectionOption from SettingsRowType
    @Binding var selectedIndex: Int
    let onSelectionChange: (Int) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        VStack(spacing: 14) {
            
            // MARK: - Header Row
            HStack(spacing: 12) {
                // Gradient icon circle
                ZStack {
                    Circle()
                        .fill(iconGradient)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Text(LocalizedStringKey(titleKey))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                // Active option indicator (small badge showing current)
                Text(LocalizedStringKey(options[selectedIndex].title))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(accentColor.opacity(0.12))
                    )
            }
            
            // MARK: - Segmented Buttons
            HStack(spacing: 6) {
                ForEach(options.indices, id: \.self) { idx in
                    segmentButton(
                        option: options[idx],
                        isSelected: selectedIndex == idx,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedIndex = idx
                                onSelectionChange(idx)
                            }
                        }
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.themeCard)
                .shadow(color: Color.themeShadow, radius: 6, x: 0, y: 3)
        )
    }
    
    // MARK: - Segment Button
    @ViewBuilder
    private func segmentButton(
        option: SelectionOption,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(spacing: 5) {
                Image(systemName: option.icon)
                    .font(.system(size: 12, weight: .medium))
                
                Text(LocalizedStringKey(option.title))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 11)
                    .fill(
                        isSelected
                        ? accentColor
                        : Color.themeBackground.opacity(isDark ? 0.5 : 0.7)
                    )
                    .shadow(
                        color: isSelected ? accentColor.opacity(0.35) : .clear,
                        radius: 4, x: 0, y: 2
                    )
            )
            .foregroundColor(isSelected ? .white : .themeSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(
                        isSelected ? Color.clear : Color.themeDivider.opacity(0.6),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Dark Mode Helper
    private var isDark: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}
