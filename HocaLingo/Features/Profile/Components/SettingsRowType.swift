//
//  SettingsRowType.swift
//  HocaLingo
//
//  ✅ NEW: Generic settings card content types for modern Profile UI
//  Supports: Toggle, Navigation, Picker, Inline Selection
//  Location: Features/Profile/Components/SettingsRowType.swift
//

import SwiftUI

// MARK: - Settings Row Type
/// Defines different content types for SettingsCard component
enum SettingsRowType {
    
    // MARK: - Toggle Type
    /// Toggle switch with optional subtitle and time display
    case toggle(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        isOn: Binding<Bool>,
        showTimePicker: Bool = false,
        selectedHour: Binding<Int>? = nil,
        onToggle: () -> Void,
        onTimeChange: ((Int) -> Void)? = nil
    )
    
    // MARK: - Navigation Type
    /// Navigates to another screen, shows current value
    case navigation(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        currentValue: String,
        destination: AnyView
    )
    
    // MARK: - Inline Selection Type
    /// Inline selection with expandable options (like Study Direction, Theme)
    case inlineSelection(
        icon: String,
        iconGradient: LinearGradient,
        title: String,
        subtitle: String,
        options: [SelectionOption],
        selectedIndex: Binding<Int>,
        onSelectionChange: (Int) -> Void
    )
    
    // MARK: - Action Type
    /// Simple button action (like Legal items, Support)
    case action(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        showChevron: Bool = true,
        action: () -> Void
    )
}

// MARK: - Selection Option Model
/// Represents a selectable option in inline selection
struct SelectionOption: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let value: Any // Can be StudyDirection, ThemeMode, AppLanguage, etc.
    
    init<T>(id: Int, icon: String, title: String, value: T) {
        self.id = id
        self.icon = icon
        self.title = title
        self.value = value
    }
}

// MARK: - Convenience Builders
extension SettingsRowType {
    
    /// Create toggle for notifications
    static func notificationToggle(
        isOn: Binding<Bool>,
        selectedHour: Binding<Int>,
        onToggle: @escaping () -> Void,
        onTimeChange: @escaping (Int) -> Void
    ) -> SettingsRowType {
        return .toggle(
            icon: "bell.fill",
            iconColor: .accentPurple,
            title: "notification_card_title",
            subtitle: isOn.wrappedValue ? String(format: "%02d:00", selectedHour.wrappedValue) : nil,
            isOn: isOn,
            showTimePicker: isOn.wrappedValue,
            selectedHour: selectedHour,
            onToggle: onToggle,
            onTimeChange: onTimeChange
        )
    }
    
    /// Create inline selection for study direction
    static func studyDirectionSelection(
        selectedDirection: Binding<StudyDirection>,
        onDirectionChange: @escaping (StudyDirection) -> Void
    ) -> SettingsRowType {
        let options = [
            SelectionOption(
                id: 0,
                icon: "arrow.right.circle.fill",
                title: "direction_en_tr_display",
                value: StudyDirection.enToTr
            ),
            SelectionOption(
                id: 1,
                icon: "arrow.left.circle.fill",
                title: "direction_tr_en_display",
                value: StudyDirection.trToEn
            )
        ]
        
        let selectedIndex = Binding<Int>(
            get: { selectedDirection.wrappedValue == .enToTr ? 0 : 1 },
            set: { newIndex in
                let newDirection: StudyDirection = newIndex == 0 ? .enToTr : .trToEn
                selectedDirection.wrappedValue = newDirection
            }
        )
        
        return .inlineSelection(
            icon: "arrow.left.arrow.right.circle.fill",
            iconGradient: LinearGradient(
                colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            title: "study_direction_card_title",
            subtitle: "study_direction_card_subtitle",
            options: options,
            selectedIndex: selectedIndex,
            onSelectionChange: { index in
                let direction: StudyDirection = index == 0 ? .enToTr : .trToEn
                onDirectionChange(direction)
            }
        )
    }
    
    /// Create inline selection for theme mode
    static func themeSelection(
        selectedTheme: Binding<ThemeMode>,
        onThemeChange: @escaping (ThemeMode) -> Void
    ) -> SettingsRowType {
        let options = [
            SelectionOption(
                id: 0,
                icon: "sun.max.fill",
                title: "theme_light_display",
                value: ThemeMode.light
            ),
            SelectionOption(
                id: 1,
                icon: "moon.fill",
                title: "theme_dark_display",
                value: ThemeMode.dark
            ),
            SelectionOption(
                id: 2,
                icon: "circle.lefthalf.filled",
                title: "theme_system_display",
                value: ThemeMode.system
            )
        ]
        
        let selectedIndex = Binding<Int>(
            get: {
                switch selectedTheme.wrappedValue {
                case .light: return 0
                case .dark: return 1
                case .system: return 2
                }
            },
            set: { newIndex in
                let newTheme: ThemeMode = [.light, .dark, .system][newIndex]
                selectedTheme.wrappedValue = newTheme
            }
        )
        
        return .inlineSelection(
            icon: "paintbrush.fill",
            iconGradient: LinearGradient(
                colors: [Color(hex: "F59E0B"), Color(hex: "FB9322")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            title: "theme_card_title",
            subtitle: "theme_card_subtitle",
            options: options,
            selectedIndex: selectedIndex,
            onSelectionChange: { index in
                let theme: ThemeMode = [.light, .dark, .system][index]
                onThemeChange(theme)
            }
        )
    }
    
    /// Create inline selection for app language
    static func languageSelection(
        selectedLanguage: Binding<AppLanguage>,
        onLanguageChange: @escaping (AppLanguage) -> Void
    ) -> SettingsRowType {
        let options = [
            SelectionOption(
                id: 0,
                icon: "flag.fill",
                title: "language_english",
                value: AppLanguage.english
            ),
            SelectionOption(
                id: 1,
                icon: "flag.fill",
                title: "language_turkish",
                value: AppLanguage.turkish
            )
        ]
        
        let selectedIndex = Binding<Int>(
            get: { selectedLanguage.wrappedValue == .english ? 0 : 1 },
            set: { newIndex in
                let newLang: AppLanguage = newIndex == 0 ? .english : .turkish
                selectedLanguage.wrappedValue = newLang
            }
        )
        
        return .inlineSelection(
            icon: "globe",
            iconGradient: LinearGradient(
                colors: [Color(hex: "10B981"), Color(hex: "4ECDC4")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            title: "language_card_title",
            subtitle: "language_card_subtitle",
            options: options,
            selectedIndex: selectedIndex,
            onSelectionChange: { index in
                let language: AppLanguage = index == 0 ? .english : .turkish
                onLanguageChange(language)
            }
        )
    }
}
