//
//  LanguageSelectionCard.swift
//  HocaLingo
//
//  Language selection card component for Profile screen
//  Location: HocaLingo/Features/Profile/Components/LanguageSelectionCard.swift
//

import SwiftUI

// MARK: - Language Selection Card
struct LanguageSelectionCard: View {
    @Binding var selectedLanguage: AppLanguage
    let onLanguageChange: (AppLanguage) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 32)
                    
                    Text("language_selection_title")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
            
            // Language Options
            ForEach(AppLanguage.allCases, id: \.self) { language in
                LanguageOptionRow(
                    language: language,
                    isSelected: selectedLanguage == language,
                    onSelect: {
                        selectedLanguage = language
                        onLanguageChange(language)
                    }
                )
                
                if language != AppLanguage.allCases.last {
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Language Option Row
struct LanguageOptionRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Flag + Language Name
                Text(language.displayNameWithFlag)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "6366F1"))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct LanguageSelectionCard_Previews: PreviewProvider {
    @State static var language = AppLanguage.turkish
    
    static var previews: some View {
        LanguageSelectionCard(
            selectedLanguage: $language,
            onLanguageChange: { lang in
                print("Language changed to: \(lang.displayName)")
            }
        )
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
