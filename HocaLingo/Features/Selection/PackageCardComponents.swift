//
//  PackageCardComponents.swift
//  HocaLingo
//
//  🔴 PREMIUM REDESIGN V2 — "Obsidian Gold"
//     - Unified deep obsidian base (both light & dark mode)
//     - Category color as subtle corner glow + icon gradient
//     - Gold signature accents: top shine, PRO chip, selection border
//     - Premium "membership card" aesthetic — Apple Card / AMEX Black feel
//  ✅ PRESERVED: PackageTabButton, StandardPackageCard unchanged
//  ✅ PRESERVED: All tap handlers, selection states, theme support
//  ✅ PRESERVED: All Text localization keys
//
//  Location: HocaLingo/Features/Selection/PackageCardComponents.swift
//

import SwiftUI

// MARK: - Tab Button Component (UNCHANGED)
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
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Standard Package Card (UNCHANGED)
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
                // Top row: icon + level badge
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 38, height: 38)

                        Image(systemName: package.iconName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(LocalizedStringKey(package.level))
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(LocalizedStringKey(package.name))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Progress section
                HStack(spacing: 6) {
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
    
    private var isCompleted: Bool { unseenCount == 0 }
    
    private var progressFraction: CGFloat {
        guard package.wordCount > 0 else { return 0 }
        let learned = max(0, package.wordCount - unseenCount)
        return CGFloat(learned) / CGFloat(package.wordCount)
    }
    
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

// MARK: - Premium Package Card (NEW — Obsidian Gold)
struct PremiumPackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let unseenCount: Int
    let isPremiumUser: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    // MARK: - Gold Palette (signature premium accent)
    private let goldPrimary   = Color(hex: "FFD700")  // Rich gold
    private let goldSecondary = Color(hex: "D4A017")  // Deep gold
    private let goldPale      = Color(hex: "FFEBA3")  // Champagne gold
    
    private var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldPrimary, goldSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Top row: icon + status/PRO chip
                HStack(alignment: .top) {
                    iconBlock
                    Spacer()
                    statusIndicator
                }
                
                Spacer()
                
                // Package name
                Text(LocalizedStringKey(package.name))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Status text
                statusText
                    .padding(.top, 4)
            }
            .padding(14)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(cardBorderOverlay)
            .overlay(goldShineLine, alignment: .top)
            .shadow(
                color: isDarkMode
                    ? Color.black.opacity(0.45)
                    : Color(hex: "1E1B2E").opacity(0.22),
                radius: isDarkMode ? 14 : 10,
                y: 6
            )
            .scaleEffect(isSelected ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Icon Block (glass container + gold gradient icon + category glow)
    private var iconBlock: some View {
        ZStack {
            // Soft category-colored glow
            RoundedRectangle(cornerRadius: 13)
                .fill(Color(hex: package.colorHex).opacity(0.45))
                .frame(width: 42, height: 42)
                .blur(radius: 6)
            
            // Glass icon container with gold border
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.16),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(goldGradient, lineWidth: 1)
                        .opacity(0.7)
                )
            
            // Icon rendered with gold gradient
            Image(systemName: package.iconName)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(goldGradient)
        }
    }
    
    // MARK: - Status Indicator (top-right)
    @ViewBuilder
    private var statusIndicator: some View {
        if !isPremiumUser {
            // Gold PRO chip for locked state
            HStack(spacing: 3) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 8, weight: .heavy))
                Text("PRO")
                    .font(.system(size: 9, weight: .heavy))
            }
            .foregroundColor(Color(hex: "1A1428"))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(goldGradient)
            .clipShape(Capsule())
            .shadow(color: goldPrimary.opacity(0.4), radius: 4, y: 1)
        } else if unseenCount == 0 {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(goldGradient)
        } else {
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(goldGradient.opacity(0.85))
        }
    }
    
    // MARK: - Status Text (bottom)
    @ViewBuilder
    private var statusText: some View {
        if !isPremiumUser {
            (Text("\(package.wordCount) ") + Text("package_words"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(goldPale.opacity(0.9))
        } else if unseenCount == 0 {
            Text("package_completed")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        } else {
            (Text("\(unseenCount) ") + Text("package_words_left"))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
        }
    }
    
    // MARK: - Card Background (Obsidian base + category glow + gold shimmer)
    private var cardBackground: some View {
        ZStack {
            // 1. Deep obsidian base — same in both modes (premium cards "break" theme)
            LinearGradient(
                colors: isDarkMode
                    ? [Color(hex: "0D0716"), Color(hex: "1A132E")]
                    : [Color(hex: "1E1832"), Color(hex: "2D2447")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 2. Category color glow — bottom-right only
            RadialGradient(
                colors: [
                    Color(hex: package.colorHex).opacity(isDarkMode ? 0.38 : 0.32),
                    Color(hex: package.colorHex).opacity(0.08),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 5,
                endRadius: 160
            )
            
            // 3. Subtle gold shimmer — top-left hint
            RadialGradient(
                colors: [
                    goldPrimary.opacity(0.10),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 100
            )
            .blendMode(.plusLighter)
            
            // 4. Inner glass finish (top highlight + bottom depth)
            LinearGradient(
                colors: [
                    Color.white.opacity(0.06),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - Border Overlay (gold when selected, subtle otherwise)
    private var cardBorderOverlay: some View {
        RoundedRectangle(cornerRadius: 22)
            .stroke(
                isSelected ? AnyShapeStyle(goldGradient) : AnyShapeStyle(borderGradient),
                lineWidth: isSelected ? 2.0 : 1.0
            )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                goldPrimary.opacity(isDarkMode ? 0.35 : 0.28),
                goldPrimary.opacity(0.08),
                goldPrimary.opacity(isDarkMode ? 0.28 : 0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Gold Shine Line (top edge accent — the "premium signature")
    private var goldShineLine: some View {
        LinearGradient(
            colors: [
                Color.clear,
                goldPrimary.opacity(0.6),
                goldPrimary.opacity(0.3),
                Color.clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.horizontal, 28)
        .padding(.top, 6)
    }
    
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}

// MARK: - Preview
struct PackageCardComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Standard card
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
                
                // Premium cards — locked (non-premium user)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ], spacing: 14) {
                    PremiumPackageCard(
                        package: PackageModel(
                            id: "premium_travel_001",
                            level: "premium_level",
                            name: "premium_package_travel",
                            description: "Tourism",
                            wordCount: 200,
                            colorHex: "FFD700",
                            isPremium: true,
                            category: .premium,
                            iconName: "airplane"
                        ),
                        isSelected: false,
                        unseenCount: 200,
                        isPremiumUser: false,
                        onTap: {}
                    )
                    
                    PremiumPackageCard(
                        package: PackageModel(
                            id: "premium_slang_001",
                            level: "premium_level",
                            name: "premium_package_slang",
                            description: "Slang",
                            wordCount: 150,
                            colorHex: "FF6B6B",
                            isPremium: true,
                            category: .premium,
                            iconName: "number.circle.fill"
                        ),
                        isSelected: true,
                        unseenCount: 150,
                        isPremiumUser: false,
                        onTap: {}
                    )
                    
                    PremiumPackageCard(
                        package: PackageModel(
                            id: "premium_business_001",
                            level: "premium_level",
                            name: "premium_package_business",
                            description: "Business",
                            wordCount: 180,
                            colorHex: "DAA520",
                            isPremium: true,
                            category: .premium,
                            iconName: "briefcase.fill"
                        ),
                        isSelected: false,
                        unseenCount: 90,
                        isPremiumUser: true,
                        onTap: {}
                    )
                    
                    PremiumPackageCard(
                        package: PackageModel(
                            id: "premium_academic_001",
                            level: "premium_level",
                            name: "premium_package_academic",
                            description: "Academic",
                            wordCount: 220,
                            colorHex: "CD853F",
                            isPremium: true,
                            category: .premium,
                            iconName: "building.columns.fill"
                        ),
                        isSelected: false,
                        unseenCount: 0,
                        isPremiumUser: true,
                        onTap: {}
                    )
                }
            }
            .padding()
        }
        .background(Color.themeBackground)
        .environment(\.themeViewModel, ThemeViewModel())
    }
}
