//
//  StudyDirectionCard.swift
//  HocaLingo
//
//  Premium study direction selection card - highly visible and distinct
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
                        .foregroundColor(.primary)
                    
                    Text("study_direction_card_subtitle")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            
            Divider()
            
            // Direction Options
            VStack(spacing: 0) {
                ForEach([StudyDirection.enToTr, StudyDirection.trToEn, StudyDirection.mixed], id: \.self) { direction in
                    DirectionOptionRow(
                        direction: direction,
                        isSelected: selectedDirection == direction,
                        onSelect: {
                            selectedDirection = direction
                            onDirectionChange(direction)
                        }
                    )
                    
                    if direction != StudyDirection.mixed {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(hex: "6366F1").opacity(0.15), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "6366F1").opacity(0.3),
                            Color(hex: "8B5CF6").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
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
                // Direction Icon
                Image(systemName: directionIcon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(hex: "6366F1") : .gray)
                    .frame(width: 32)
                
                // Direction Name
                Text(direction.displayName)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color(hex: "6366F1") : .primary)
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "6366F1").opacity(0.1))
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "6366F1"))
                    }
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color(hex: "6366F1").opacity(0.05) : Color.clear)
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
        case .mixed:
            return "shuffle.circle.fill"
        }
    }
}

// MARK: - Preview
struct StudyDirectionCard_Previews: PreviewProvider {
    @State static var direction = StudyDirection.enToTr
    
    static var previews: some View {
        StudyDirectionCard(
            selectedDirection: $direction,
            onDirectionChange: { dir in
                print("Direction changed to: \(dir.displayName)")
            }
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
