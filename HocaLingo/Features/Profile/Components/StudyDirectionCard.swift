//
//  StudyDirectionCard.swift
//  HocaLingo
//
//  ✅ UPDATED: Removed mixed option, added dark theme support
//  Location: HocaLingo/Features/Profile/Components/StudyDirectionCard.swift
//

import SwiftUI

// MARK: - Study Direction Card
struct StudyDirectionCard: View {
    @Binding var selectedDirection: StudyDirection
    let onDirectionChange: (StudyDirection) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Icon and Title
            HStack(spacing: 12) {
                // Gradient Icon Background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "6366F1"),
                                    Color(hex: "8B5CF6")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("study_direction_card_title")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.themePrimary)
                    
                    Text("study_direction_card_subtitle")
                        .font(.system(size: 13))
                        .foregroundColor(.themeSecondary)
                }
                
                Spacer()
            }
            .padding(16)
            
            Divider()
                .background(Color.themeDivider)
            
            // Direction Options (ONLY 2 OPTIONS - NO MIXED)
            VStack(spacing: 0) {
                DirectionOptionRow(
                    direction: .enToTr,
                    isSelected: selectedDirection == .enToTr,
                    onSelect: {
                        selectedDirection = .enToTr
                        onDirectionChange(.enToTr)
                    }
                )
                
                Divider()
                    .padding(.leading, 60)
                    .background(Color.themeDivider)
                
                DirectionOptionRow(
                    direction: .trToEn,
                    isSelected: selectedDirection == .trToEn,
                    onSelect: {
                        selectedDirection = .trToEn
                        onDirectionChange(.trToEn)
                    }
                )
            }
        }
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Direction Option Row
struct DirectionOptionRow: View {
    let direction: StudyDirection
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: directionIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentPurple : .themeSecondary)
                    .frame(width: 32)
                
                Text(direction.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var directionIcon: String {
        switch direction {
        case .enToTr:
            return "arrow.right.circle.fill"
        case .trToEn:
            return "arrow.left.circle.fill"
        }
    }
}

// MARK: - Preview
struct StudyDirectionCard_Previews: PreviewProvider {
    @State static var direction = StudyDirection.enToTr
    
    static var previews: some View {
        Group {
            StudyDirectionCard(
                selectedDirection: $direction,
                onDirectionChange: { dir in
                    print("Direction changed to: \(dir.displayName)")
                }
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Theme")
            
            StudyDirectionCard(
                selectedDirection: $direction,
                onDirectionChange: { dir in
                    print("Direction changed to: \(dir.displayName)")
                }
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Theme")
        }
    }
}
