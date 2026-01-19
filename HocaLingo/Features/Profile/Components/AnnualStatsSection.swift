//
//  AnnualStatsSection.swift
//  HocaLingo
//
//  ✅ REDESIGNED: Compact horizontal 3-card layout for annual statistics
//  Location: HocaLingo/Features/Profile/Components/AnnualStatsSection.swift
//

import SwiftUI

// MARK: - Annual Stats Section (COMPACT LAYOUT)
struct AnnualStatsSection: View {
    let annualStats: AnnualStats
    
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("annual_stats_title")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.themePrimary)
                Spacer()
            }
            
            // Compact 3-card horizontal layout
            HStack(spacing: 12) {
                // Active Days Card
                CompactStatCard(
                    icon: "calendar.circle.fill",
                    title: "annual_stats_days_label",
                    value: "\(annualStats.activeDaysThisYear)",
                    color: .accentGreen
                )
                
                // Study Hours Card
                CompactStatCard(
                    icon: "clock.circle.fill",
                    title: "annual_stats_hours_label",
                    value: "\(annualStats.studyHoursThisYear)",
                    color: .accentPurple
                )
                
                // Words Skipped Card
                CompactStatCard(
                    icon: "hand.raised.circle.fill",
                    title: "annual_stats_skipped_label",
                    value: "\(annualStats.wordsSkippedThisYear)",
                    color: .accentOrange
                )
            }
        }
    }
}

// MARK: - Compact Stat Card (Small Card Design)
struct CompactStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.themePrimary)
                .lineLimit(1)
            
            // Label
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(Color.themeCard)
        .cornerRadius(12)
        .shadow(color: Color.themeShadow, radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview
struct AnnualStatsSection_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnnualStatsSection(
                annualStats: AnnualStats(
                    activeDaysThisYear: 45,
                    studyHoursThisYear: 23,
                    wordsSkippedThisYear: 120
                )
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Theme")
            
            AnnualStatsSection(
                annualStats: AnnualStats(
                    activeDaysThisYear: 45,
                    studyHoursThisYear: 23,
                    wordsSkippedThisYear: 120
                )
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Theme")
        }
    }
}
