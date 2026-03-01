//
//  PackageCardComponents.swift
//  HocaLingo
//
//  🔴 REDESIGN: Unified card design for both Standard and Premium
//     - SF Symbols icons instead of emojis
//     - Progress bar on standard cards
//     - Description text on premium cards
//     - Consistent anatomy: icon top-left, badge top-right, name + status bottom
//  🔴 REDESIGN: PackageTabButton — larger, full-width with animated slider
//  ✅ PRESERVED: All tap handlers, selection states, theme support
//
//  Location: HocaLingo/Features/Selection/PackageCardComponents.swift
//

import SwiftUI

// MARK: - Tab Button Component (REDESIGNED — larger, full-width ready)
struct PackageTabButton: View {
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let showBadge: Bool
    let action: () -> Void
    
    init(
        title: LocalizedStringKey,
        icon: String,
        isSelected: Bool,
        accentColor: Color,
        showBadge: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.showBadge = showBadge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                
                // PRO badge for premium tab
                if showBadge {
                    Text("PRO")
                        .font(.system(size: 9, weight: .heavy))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            isSelected
                                ? Color.white.opacity(0.25)
                                : accentColor.opacity(0.2)
                        )
                        .foregroundColor(isSelected ? .white : accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            // Background is transparent — the animated slider behind handles selected state
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Standard Package Card (REDESIGNED — SF Symbol icon + progress bar)
struct StandardPackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let unseenCount: Int
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Top row: SF Symbol icon + level badge
                HStack {
                    // Package icon in a rounded square
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: package.iconName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Level badge
                    Text(LocalizedStringKey(package.level))
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Bottom: Package name
                Text(LocalizedStringKey(package.name))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Progress section
                HStack(spacing: 6) {
                    // Mini progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(isCompleted ? Color(hex: "4ECDC4") : Color.white.opacity(0.7))
                                .frame(width: geo.size.width * progressFraction)
                        }
                    }
                    .frame(height: 4)
                    
                    // Status indicator
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "4ECDC4"))
                    } else {
                        Text("\(unseenCount)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                .padding(.top, 8)
            }
            .padding(14)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        isSelected ? Color.themePrimaryButton : Color.clear,
                        lineWidth: 2.5
                    )
            )
            .shadow(
                color: Color(hex: package.colorHex).opacity(isDarkMode ? 0.3 : 0.2),
                radius: 8,
                y: 4
            )
            .scaleEffect(isSelected ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    
    private var isCompleted: Bool { unseenCount == 0 }
    
    private var progressFraction: CGFloat {
        guard package.wordCount > 0 else { return 0 }
        let learned = max(0, package.wordCount - unseenCount)
        return CGFloat(learned) / CGFloat(package.wordCount)
    }
    
    // Solid purple gradient — consistent in both dark and light mode
    private var cardGradient: LinearGradient {
        isDarkMode
            ? LinearGradient(
                colors: [
                    Color(hex: package.colorHex).opacity(1.0),
                    Color(hex: package.colorHex).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [
                    Color(hex: package.colorHex).opacity(0.90),
                    Color(hex: package.colorHex).opacity(0.74)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
    
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}

// MARK: - Premium Package Card (REDESIGNED — unified anatomy with standard)
struct PremiumPackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let unseenCount: Int
    let isPremiumUser: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Top row: SF Symbol icon + PRO badge
                HStack {
                    // Package icon in a gold-tinted rounded square
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "FFD700").opacity(isDarkMode ? 0.15 : 0.12))
                            .frame(width: 38, height: 38)
                        
                        Image(systemName: package.iconName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "FFD700"))
                    }
                    
                    Spacer()
                    
                    // Lock or checkmark status
                    if !isPremiumUser {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FFD700").opacity(0.7))
                    } else if unseenCount == 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "4ECDC4"))
                    } else {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "FFD700").opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Package name
                Text(LocalizedStringKey(package.name))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Status text
                if !isPremiumUser {
                    Text("package_premium_required")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "FFD700"))
                        .padding(.top, 4)
                } else if unseenCount == 0 {
                    Text("package_completed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.themeSecondary)
                        .padding(.top, 4)
                } else {
                    (Text("\(unseenCount) ") + Text("package_words_left"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.themeSecondary)
                        .padding(.top, 4)
                }
            }
            .padding(14)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(cardBorderColor, lineWidth: cardBorderWidth)
            )
            .shadow(
                color: isDarkMode ? Color.clear : Color(hex: package.colorHex).opacity(0.15),
                radius: 8,
                y: 4
            )
            .scaleEffect(isSelected ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Card Styling
    
    private var cardBackground: some View {
        ZStack {
            // Subtle gradient tint from package color
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: package.colorHex).opacity(isDarkMode ? 0.12 : 0.08),
                            Color(hex: package.colorHex).opacity(isDarkMode ? 0.06 : 0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Glass material overlay
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .opacity(isDarkMode ? 0.6 : 0.5)
        }
    }
    
    private var cardBorderColor: Color {
        if isSelected {
            return Color(hex: "FFD700")
        } else if !isPremiumUser {
            return Color(hex: "FFD700").opacity(isDarkMode ? 0.25 : 0.18)
        } else {
            return Color.clear
        }
    }
    
    private var cardBorderWidth: CGFloat {
        isSelected ? 2.5 : 1.5
    }
    
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}

// MARK: - Preview
struct PackageCardComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            StandardPackageCard(
                package: PackageModel(
                    id: "standard_a1_001",
                    level: "level_a1",
                    name: "package_name_beginner",
                    description: "Basic words",
                    wordCount: 100,
                    colorHex: "9B8FD4",
                    isPremium: false,
                    category: .standard,
                    iconName: "leaf.fill"
                ),
                isSelected: false,
                unseenCount: 50,
                onTap: {}
            )
            
            PremiumPackageCard(
                package: PackageModel(
                    id: "premium_travel_001",
                    level: "premium_level",
                    name: "premium_package_travel",
                    description: "Tourism and navigation",
                    wordCount: 200,
                    colorHex: "FFD700",
                    isPremium: true,
                    category: .premium,
                    iconName: "airplane"
                ),
                isSelected: false,
                unseenCount: 100,
                isPremiumUser: false,
                onTap: {}
            )
        }
        .padding()
        .background(Color.themeBackground)
    }
}
