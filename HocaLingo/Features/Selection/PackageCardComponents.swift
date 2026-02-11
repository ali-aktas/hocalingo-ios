//
//  PackageCardComponents.swift
//  HocaLingo
//
//  🔴 REDESIGN:
//    - PackageTabButton: smaller font (13→ was 15), more rounded corners (16 → was 10)
//    - StandardPackageCard: solid consistent gradient both themes
//      Dark:  opacity 1.0 → 0.82 (rich/deep)
//      Light: opacity 0.90 → 0.74 (vivid, no more washed-out pastel)
//      Text:  always white (purple bg has enough contrast in both modes)
//  ✅ PRESERVED: PremiumPackageCard completely untouched
//  ✅ PRESERVED: All logic, selection states, unseenCount display
//
//  Location: HocaLingo/Features/Selection/PackageCardComponents.swift
//

import SwiftUI

// MARK: - Tab Button Component (REDESIGNED)
struct PackageTabButton: View {
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold)) // was 14
                Text(title)
                    .font(.system(size: 13, weight: .semibold)) // was 15
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.vertical, 8)                              // was 10
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 13)              // was 10 → more rounded
                    .fill(isSelected ? accentColor : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Standard Package Card (REDESIGNED — solid consistent gradient)
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
                // Top row: level badge + status icon
                HStack {
                    Text(LocalizedStringKey(package.level))
                        .font(.system(size: 13, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        // White badge on purple — consistent in both themes
                        .background(Color.white.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: unseenCount == 0 ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color.white.opacity(0.85))
                }
                
                Spacer()
                
                // Bottom row: package name + word count
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(package.name))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)        // Always white — purple bg has contrast
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    if unseenCount == 0 {
                        Text("package_completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.75))
                    } else {
                        (Text("\(unseenCount) ") + Text("package_words_left"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.75))
                    }
                }
            }
            .padding(16)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.themePrimaryButton : Color.clear, lineWidth: 3)
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
    
    // Solid purple gradient — same feeling in both dark and light mode
    // Opacity numbers chosen so the card looks rich without being garish
    private var cardGradient: LinearGradient {
        isDarkMode
            ? LinearGradient(
                colors: [
                    Color(hex: package.colorHex).opacity(1.0),   // Full saturation in dark
                    Color(hex: package.colorHex).opacity(0.82)   // Slight darkening at bottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            : LinearGradient(
                colors: [
                    Color(hex: package.colorHex).opacity(0.90),  // Vivid in light — not washed out
                    Color(hex: package.colorHex).opacity(0.74)   // Slight darkening at bottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
    }
    
    private var isDarkMode: Bool { themeViewModel.isDarkMode(in: colorScheme) }
}

// MARK: - Premium Package Card (UNCHANGED)
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
            ZStack {
                // Glassmorphism Background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: package.colorHex).opacity(isDarkMode ? 0.3 : 0.2),
                                Color(hex: package.colorHex).opacity(isDarkMode ? 0.15 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Glass overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        // Crown icon
                        Image(systemName: "crown.fill")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(Color(hex: "FFD700"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(hex: "FFD700").opacity(0.15))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        if !isPremiumUser {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "FFD700"))
                        } else {
                            Image(systemName: unseenCount == 0 ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "FFD700").opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(package.name))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.themePrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        
                        if !isPremiumUser {
                            Text("package_premium_required")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "FFD700"))
                        } else if unseenCount == 0 {
                            Text("package_completed")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.themeSecondary)
                        } else {
                            (Text("\(unseenCount) ") + Text("package_words_left"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.themeSecondary)
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected
                            ? Color(hex: "FFD700")
                            : (isPremiumUser ? Color.clear : Color(hex: "FFD700").opacity(0.4)),
                        lineWidth: isSelected ? 3 : 1.5
                    )
            )
            .shadow(
                color: isDarkMode ? Color.clear : Color(hex: package.colorHex).opacity(0.2),
                radius: 8,
                y: 4
            )
            .scaleEffect(isSelected ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
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
                    colorHex: "9285C4",
                    isPremium: false,
                    category: .standard
                ),
                isSelected: false,
                unseenCount: 50,
                onTap: {}
            )
            
            PremiumPackageCard(
                package: PackageModel(
                    id: "premium_business_001",
                    level: "premium_level",
                    name: "premium_package_business",
                    description: "Business English",
                    wordCount: 200,
                    colorHex: "DAA520",
                    isPremium: true,
                    category: .premium
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
