//
//  LanguageSelectionCard.swift
//  HocaLingo
//
//  ✅ UPDATED: Added dark theme support for language selection card
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
                        .foregroundColor(.accentPurple)
                        .frame(width: 32)
                    
                    Text("language_selection_title")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themePrimary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.themeDivider)
            
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
                        .background(Color.themeDivider)
                }
            }
        }
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
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
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.themeTertiary)
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
        Group {
            LanguageSelectionCard(
                selectedLanguage: $language,
                onLanguageChange: { lang in
                    print("Language changed to: \(lang.displayName)")
                }
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Theme")
            
            LanguageSelectionCard(
                selectedLanguage: $language,
                onLanguageChange: { lang in
                    print("Language changed to: \(lang.displayName)")
                }
            )
            .padding()
            .background(Color.themeBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Theme")
        }
    }
}
