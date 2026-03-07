//
//  StudyCompletionView.swift
//  HocaLingo
//
//  ✅ FIXED: All hardcoded Turkish strings replaced with L() localization keys
//  Location: HocaLingo/Features/Study/StudyCompletionView.swift
//

import SwiftUI

// MARK: - Study Completion View
struct StudyCompletionView: View {
    @Binding var selectedTab: Int
    let onContinue: () -> Void
    let onRestart: () -> Void

    @State private var showPackageSelection = false
    @State private var selectedTabForSheet: Int = 0
    @State private var animateSuccess = false
    @State private var currentMessageIndex = 0

    // Localization key pairs: (title_key, subtitle_key)
    private let messageKeys: [(String, String)] = [
        ("study_completion_title_1", "study_completion_subtitle_1"),
        ("study_completion_title_2", "study_completion_subtitle_2"),
        ("study_completion_title_3", "study_completion_subtitle_3"),
        ("study_completion_title_4", "study_completion_subtitle_4"),
        ("study_completion_title_5", "study_completion_subtitle_5")
    ]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Image("lingohoca2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .scaleEffect(animateSuccess ? 1.0 : 0.5)
                        .opacity(animateSuccess ? 1.0 : 0.0)

                    VStack(spacing: 12) {
                        // Title — localized at runtime
                        Text(L(messageKeys[currentMessageIndex].0))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)

                        // Subtitle — localized at runtime
                        Text(L(messageKeys[currentMessageIndex].1))
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(animateSuccess ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.4).delay(0.2), value: animateSuccess)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    // Home button
                    Button(action: {
                        selectedTab = 0
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                            Text(L("study_completion_home_button"))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(16)
                        .shadow(color: Color(hex: "4ECDC4").opacity(0.3), radius: 12, x: 0, y: 6)
                    }

                    // Package selection button
                    Button(action: {
                        showPackageSelection = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 18))
                            Text(L("study_completion_packages_button"))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(hex: "4ECDC4").opacity(0.12))
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animateSuccess ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.4).delay(0.4), value: animateSuccess)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            currentMessageIndex = Int.random(in: 0..<messageKeys.count)
            withAnimation {
                animateSuccess = true
            }
        }
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView(selectedTab: $selectedTabForSheet)
                .onDisappear {
                    if selectedTabForSheet == 1 {
                        selectedTab = 1
                    }
                }
        }
    }
}

// MARK: - Preview
#Preview {
    StudyCompletionView(
        selectedTab: .constant(1),
        onContinue: {},
        onRestart: {}
    )
}
