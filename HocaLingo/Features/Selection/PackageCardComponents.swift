//
//  PackageCardComponents.swift
//  HocaLingo
//
//  Package card components for selection view
//  Location: HocaLingo/Features/Selection/PackageCardComponents.swift
//

import SwiftUI

// MARK: - Tab Button Component
struct PackageTabButton: View {
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? accentColor : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Standard Package Card
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
                HStack {
                    Text(LocalizedStringKey(package.level))
                        .font(.system(size: 13, weight: .heavy))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(isDarkMode ? Color.white.opacity(0.25) : Color.black.opacity(0.12))
                        .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.8))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: unseenCount == 0 ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isDarkMode ? .white.opacity(0.8) : Color.black.opacity(0.6))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedStringKey(package.name))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(isDarkMode ? .white : Color.black.opacity(0.9))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    if unseenCount == 0 {
                        Text("package_completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.5))
                    } else {
                        (Text("\(unseenCount) ") + Text("package_words_left"))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.5))
                    }
                }
            }
            .padding(16)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        isDarkMode
                        ? LinearGradient(
                            colors: [
                                Color(hex: package.colorHex).opacity(0.8),
                                Color(hex: package.colorHex).opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                Color(hex: package.colorHex).opacity(0.3),
                                Color(hex: package.colorHex).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color.themePrimaryButton : Color.clear, lineWidth: 3)
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

// MARK: - Premium Package Card (Glassmorphism)
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
                                Color(hex: package.colorHex).opacity(isDarkMode ? 0.2 : 0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700").opacity(0.5),
                                        Color(hex: "FFA500").opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        // Premium Badge
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text(LocalizedStringKey(package.level))
                                .font(.system(size: 12, weight: .heavy))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700"),
                                    Color(hex: "FFA500")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        
                        Spacer()
                        
                        if isPremiumUser {
                            Image(systemName: unseenCount == 0 ? "checkmark.circle.fill" : "chevron.right.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "FFD700"))
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "FFD700"))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(package.name))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.themePrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        
                        if isPremiumUser {
                            if unseenCount == 0 {
                                Text("package_completed")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.themeSecondary)
                            } else {
                                (Text("\(unseenCount) ") + Text("package_words_left"))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.themeSecondary)
                            }
                        } else {
                            Text("premium_unlock_required")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "FFD700"))
                        }
                    }
                }
                .padding(16)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .shadow(
                color: Color(hex: "FFD700").opacity(0.3),
                radius: 12,
                y: 6
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? Color(hex: "FFD700") : Color.clear, lineWidth: 3)
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
                    colorHex: "FF6B6B",
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
