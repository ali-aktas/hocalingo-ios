//
//  PremiumSheetPlaceholder.swift
//  HocaLingo
//
//  Shared premium sheet placeholder for all views
//  Location: HocaLingo/Features/Premium/PremiumSheetPlaceholder.swift
//

import SwiftUI

// MARK: - Premium Sheet Placeholder
struct PremiumSheetPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "FFD700").opacity(0.1),
                        Color(hex: "FFA500").opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Crown Icon with Glow
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "FFA500")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 30)
                            .opacity(0.6)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FFD700"),
                                        Color(hex: "FFA500")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Title & Subtitle
                    VStack(spacing: 12) {
                        Text("Premium Coming Soon")
                            .font(.system(size: 32, weight: .black))
                            .foregroundColor(.themePrimary)
                        
                        Text("Premium features will be available soon.\nStay tuned for exclusive content!")
                            .font(.system(size: 17))
                            .foregroundColor(.themeSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 40)
                    
                    // Features Preview (Optional)
                    VStack(spacing: 16) {
                        premiumFeature(icon: "infinity", text: "Unlimited word selections")
                        premiumFeature(icon: "sparkles", text: "Exclusive premium packages")
                        premiumFeature(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics")
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
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
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Feature Row
    private func premiumFeature(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "FFD700"))
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.themeSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct PremiumSheetPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSheetPlaceholder()
    }
}
