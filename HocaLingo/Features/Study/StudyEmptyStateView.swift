//
//  StudyEmptyStateView.swift
//  HocaLingo
//
//  ✅ FIX: showPackageSelection is now a @Binding — sheet lives in StudyView.
//  ✅ LOCALIZED: All hardcoded Turkish strings replaced with L() keys.
//  Location: HocaLingo/Features/Study/StudyEmptyStateView.swift
//

import SwiftUI

// MARK: - Study Empty State View
struct StudyEmptyStateView: View {
    @Binding var selectedTab: Int
    @Binding var showPackageSelection: Bool
    let isFirstTime: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(isFirstTime ? "lingohoca3" : "lingohoca2")
                .resizable()
                .scaledToFit()
                .frame(width: isFirstTime ? 200 : 180, height: isFirstTime ? 200 : 180)

            VStack(spacing: 12) {
                Text(L(isFirstTime ? "study_empty_welcome_title" : "study_empty_completed_title"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(L(isFirstTime ? "study_empty_welcome_subtitle" : "study_empty_completed_subtitle"))
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 16) {
                Button(action: {
                    showPackageSelection = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: isFirstTime ? "plus.circle.fill" : "square.grid.2x2.fill")
                            .font(.system(size: 20))

                        Text(L(isFirstTime ? "study_empty_select_words_button" : "study_empty_browse_packages_button"))
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 10, x: 0, y: 5)
                }

                Button(action: {
                    selectedTab = 0
                }) {
                    Text(L("study_empty_go_home_button"))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "4ECDC4").opacity(0.1))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        // No .sheet here — lives in StudyView to avoid auto-dismiss bug
    }
}
