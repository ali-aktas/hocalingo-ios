//
//  AnnualStatsSection.swift
//  HocaLingo
//
//  Annual statistics section - displays 3 key yearly metrics
//  Location: HocaLingo/Features/Profile/Components/AnnualStatsSection.swift
//

import SwiftUI

// MARK: - Annual Stats Section
struct AnnualStatsSection: View {
    let annualStats: AnnualStats
    
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("annual_stats_title")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Stats Grid (3 cards)
            VStack(spacing: 12) {
                // Row 1: Active Days
                AnnualStatCard(
                    icon: "calendar.circle.fill",
                    title: "annual_stats_days_label",
                    value: "\(annualStats.activeDaysThisYear)",
                    color: Color(hex: "10B981")
                )
                
                // Row 2: Study Hours
                AnnualStatCard(
                    icon: "clock.circle.fill",
                    title: "annual_stats_hours_label",
                    value: "\(annualStats.studyHoursThisYear)",
                    color: Color(hex: "6366F1")
                )
                
                // Row 3: Words Skipped
                AnnualStatCard(
                    icon: "hand.raised.circle.fill",
                    title: "annual_stats_skipped_label",
                    value: "\(annualStats.wordsSkippedThisYear)",
                    color: Color(hex: "F59E0B")
                )
            }
        }
    }
}

// MARK: - Annual Stat Card
struct AnnualStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
struct AnnualStatsSection_Previews: PreviewProvider {
    static var previews: some View {
        AnnualStatsSection(
            annualStats: AnnualStats(
                activeDaysThisYear: 45,
                studyHoursThisYear: 23,
                wordsSkippedThisYear: 120
            )
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
