//
//  LegalSupportSection.swift
//  HocaLingo
//
//  Legal and support section with working links
//  Location: HocaLingo/Features/Profile/Components/LegalSupportSection.swift
//

import SwiftUI
import StoreKit

// MARK: - Legal & Support Section
struct LegalSupportSection: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("legal_title")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Privacy Policy
            LegalRow(
                icon: "lock.shield.fill",
                title: "legal_privacy",
                action: {
                    openPrivacyPolicy()
                }
            )
            
            Divider()
            
            // Terms of Service
            LegalRow(
                icon: "doc.text.fill",
                title: "legal_terms",
                action: {
                    openTermsOfService()
                }
            )
            
            Divider()
            
            // Rate App
            LegalRow(
                icon: "star.fill",
                title: "legal_rate_app",
                action: {
                    requestReview()
                }
            )
            
            Divider()
            
            // Contact Support
            LegalRow(
                icon: "envelope.fill",
                title: "legal_support",
                subtitle: "legal_support_subtitle",
                action: {
                    openContactSupport()
                }
            )
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Actions
    
    private func openPrivacyPolicy() {
        // TODO: Update with actual privacy policy URL
        if let url = URL(string: "https://hocalingo.com/privacy") {
            openURL(url)
        }
    }
    
    private func openTermsOfService() {
        // TODO: Update with actual terms URL
        if let url = URL(string: "https://hocalingo.com/terms") {
            openURL(url)
        }
    }
    
    private func requestReview() {
        // Request App Store review using StoreKit
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openContactSupport() {
        // Open email client with pre-filled support email
        let email = "support@hocalingo.com"
        let subject = "HocaLingo Support"
        let body = "Hello HocaLingo Team,"
        
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
}

// MARK: - Legal Row
struct LegalRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "6366F1"))
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct LegalSupportSection_Previews: PreviewProvider {
    static var previews: some View {
        LegalSupportSection()
            .padding()
            .background(Color.gray.opacity(0.1))
    }
}
