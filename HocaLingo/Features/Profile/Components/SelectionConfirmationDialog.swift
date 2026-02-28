//
//  SelectionConfirmationDialog.swift
//  HocaLingo
//
//  Clean confirmation overlay shown after settings changes
//  Auto-dismisses after 1.8 seconds, also tappable to dismiss
//  Location: Features/Profile/Components/SelectionConfirmationDialog.swift
//

import SwiftUI

// MARK: - Confirmation Info Model
/// Data model carrying confirmation dialog content
struct ConfirmationInfo {
    let icon: String
    let iconColor: Color
    let titleKey: String      // Localizable.strings key
    let valueText: String     // Pre-resolved display string (supports formatted values like "09:00")
}

// MARK: - Confirmation Dialog View
struct SelectionConfirmationDialog: View {
    let info: ConfirmationInfo
    @Binding var isShowing: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            // Dialog card
            VStack(spacing: 20) {
                
                // Animated icon badge
                ZStack {
                    Circle()
                        .fill(info.iconColor.opacity(0.15))
                        .frame(width: 72, height: 72)
                    
                    Circle()
                        .stroke(info.iconColor.opacity(0.25), lineWidth: 2)
                        .frame(width: 72, height: 72)
                    
                    Image(systemName: info.icon)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(info.iconColor)
                }
                .scaleEffect(isShowing ? 1.0 : 0.5)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: isShowing)
                
                // Texts
                VStack(spacing: 6) {
                    Text(LocalizedStringKey(info.titleKey))
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .multilineTextAlignment(.center)
                    
                    // Selected value highlighted
                    Text(info.valueText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(info.iconColor.opacity(0.85))
                        )
                }
                
                // OK button
                Button(action: dismiss) {
                    Text("OK")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [info.iconColor, info.iconColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.themeCard)
                    .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
            )
            .padding(.horizontal, 48)
            .scaleEffect(isShowing ? 1.0 : 0.85)
            .opacity(isShowing ? 1.0 : 0.0)
        }
        .onAppear {
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                dismiss()
            }
        }
    }
    
    // MARK: - Dismiss
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            isShowing = false
        }
    }
}
