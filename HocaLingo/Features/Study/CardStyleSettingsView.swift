//
//  CardStyleSettingsView.swift
//  HocaLingo
//
//  Card style settings sheet
//  Location: HocaLingo/Features/Study/CardStyleSettingsView.swift
//

import SwiftUI

// MARK: - Card Style Settings View
/// Settings sheet for selecting card design style
struct CardStyleSettingsView: View {
    @ObservedObject var viewModel: StudyViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStyle: CardStyle
    @State private var showPaywall: Bool = false
    
    init(viewModel: StudyViewModel) {
        self.viewModel = viewModel
        self._selectedStyle = State(initialValue: viewModel.cardStyle)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                Text("card_style_settings_subtitle")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                
                // Style options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(CardStyle.allCases, id: \.self) { style in
                            CardStyleOptionRow(
                                style: style,
                                isSelected: selectedStyle == style,
                                isPremium: PremiumManager.shared.isPremium,
                                onTap: {
                                    handleStyleSelection(style)
                                }
                            )
                        }
                    }
                    .padding(24)
                }
                
                Spacer()
                
                // Apply button
                Button(action: applyStyle) {
                    Text("apply")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("card_style_settings_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 22))
                    }
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            // ✅ TODO: Replace with actual PaywallView
            PaywallPlaceholderView()
        }
    }
    
    private func handleStyleSelection(_ style: CardStyle) {
        // Check if premium required
        if style.requiresPremium && !PremiumManager.shared.isPremium {
            showPaywall = true
            return
        }
        
        selectedStyle = style
    }
    
    private func applyStyle() {
        // Save to UserDefaults
        UserDefaultsManager.shared.saveCardStyle(selectedStyle)
        
        // Update ViewModel
        viewModel.cardStyle = selectedStyle
        
        // Close sheet
        dismiss()
    }
}

// MARK: - Card Style Option Row
struct CardStyleOptionRow: View {
    let style: CardStyle
    let isSelected: Bool
    let isPremium: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 22))
                        .foregroundColor(iconColor)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(LocalizedStringKey(style.displayName))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        // Premium badge
                        if style.requiresPremium {
                            Text("Premium")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(LocalizedStringKey(style.displayName + "_description"))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "4ECDC4"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "4ECDC4") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackground: Color {
        if isSelected {
            return Color(hex: "4ECDC4").opacity(0.15)
        } else {
            return Color.gray.opacity(0.1)
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return Color(hex: "4ECDC4")
        } else {
            return .secondary
        }
    }
}

// MARK: - Paywall Placeholder
/// Temporary paywall view (replace with actual implementation)
struct PaywallPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "crown.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(hex: "FFD700"))
            
            Text("Premium Feature")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Upgrade to Premium to unlock beautiful gradient card designs")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    // TODO: Implement premium purchase
                    print("🛒 Premium purchase initiated")
                    dismiss()
                }) {
                    Text("Upgrade to Premium")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
                
                Button(action: { dismiss() }) {
                    Text("Maybe Later")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Preview
#Preview {
    let viewModel = StudyViewModel()
    return CardStyleSettingsView(viewModel: viewModel)
}
