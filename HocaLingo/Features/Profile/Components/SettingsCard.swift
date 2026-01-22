//
//  SettingsCard.swift
//  HocaLingo
//
//  ✅ NEW: Modern generic settings card component
//  Single reusable card for all Profile settings
//  Supports: Toggle, Navigation, Inline Selection, Actions
//  Location: Features/Profile/Components/SettingsCard.swift
//

import SwiftUI

// MARK: - Settings Card
/// Generic reusable card component for Profile settings
/// Supports multiple content types: toggle, navigation, inline selection, actions
struct SettingsCard: View {
    let type: SettingsRowType
    @State private var isExpanded: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            switch type {
            case .toggle(let icon, let iconColor, let title, let subtitle, let isOn, let showTimePicker, let selectedHour, let onToggle, let onTimeChange):
                toggleCard(
                    icon: icon,
                    iconColor: iconColor,
                    title: title,
                    subtitle: subtitle,
                    isOn: isOn,
                    showTimePicker: showTimePicker,
                    selectedHour: selectedHour,
                    onToggle: onToggle,
                    onTimeChange: onTimeChange
                )
                
            case .navigation(let icon, let iconColor, let title, let subtitle, let currentValue, let destination):
                navigationCard(
                    icon: icon,
                    iconColor: iconColor,
                    title: title,
                    subtitle: subtitle,
                    currentValue: currentValue,
                    destination: destination
                )
                
            case .inlineSelection(let icon, let iconGradient, let title, let subtitle, let options, let selectedIndex, let onSelectionChange):
                inlineSelectionCard(
                    icon: icon,
                    iconGradient: iconGradient,
                    title: title,
                    subtitle: subtitle,
                    options: options,
                    selectedIndex: selectedIndex,
                    onSelectionChange: onSelectionChange
                )
                
            case .action(let icon, let iconColor, let title, let subtitle, let showChevron, let action):
                actionCard(
                    icon: icon,
                    iconColor: iconColor,
                    title: title,
                    subtitle: subtitle,
                    showChevron: showChevron,
                    action: action
                )
            }
        }
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Toggle Card
    private func toggleCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        isOn: Binding<Bool>,
        showTimePicker: Bool,
        selectedHour: Binding<Int>?,
        onToggle: @escaping () -> Void,
        onTimeChange: ((Int) -> Void)?
    ) -> some View {
        VStack(spacing: 0) {
            // Header with Toggle
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themePrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.themeSecondary)
                    }
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .onChange(of: isOn.wrappedValue) { _ in
                        onToggle()
                    }
            }
            .padding(16)
            
            // Time Picker (shown when enabled)
            if showTimePicker, let selectedHour = selectedHour, let onTimeChange = onTimeChange {
                Divider()
                    .background(Color.themeDivider)
                
                VStack(spacing: 12) {
                    Text("Select notification time")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.themeSecondary)
                    
                    // Hour Picker
                    Picker("Hour", selection: selectedHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d:00", hour))
                                .tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                    .onChange(of: selectedHour.wrappedValue) { oldValue, newValue in
                        onTimeChange(newValue)  // ✅ Call callback when time changes
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showTimePicker)
    }
    
    // MARK: - Navigation Card
    private func navigationCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        currentValue: String,
        destination: AnyView
    ) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themePrimary)
                    
                    if let subtitle = subtitle {
                        Text(LocalizedStringKey(subtitle))
                            .font(.system(size: 13))
                            .foregroundColor(.themeSecondary)
                    }
                }
                
                Spacer()
                
                // Current Value + Chevron
                HStack(spacing: 8) {
                    Text(currentValue)
                        .font(.system(size: 14))
                        .foregroundColor(.themeSecondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Inline Selection Card
    private func inlineSelectionCard(
        icon: String,
        iconGradient: LinearGradient,
        title: String,
        subtitle: String,
        options: [SelectionOption],
        selectedIndex: Binding<Int>,
        onSelectionChange: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 0) {
            // Header (Always visible)
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Gradient Icon
                    ZStack {
                        Circle()
                            .fill(iconGradient)
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    
                    // Title & Subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text(LocalizedStringKey(title))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.themePrimary)
                        
                        Text(LocalizedStringKey(subtitle))
                            .font(.system(size: 13))
                            .foregroundColor(.themeSecondary)
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse Icon
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.themeTertiary)
                }
                .padding(16)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Options (Expandable)
            if isExpanded {
                Divider()
                    .background(Color.themeDivider)
                
                VStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                        Button(action: {
                            selectedIndex.wrappedValue = index
                            onSelectionChange(index)
                            
                            // Auto-collapse after selection
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isExpanded = false
                                }
                            }
                        }) {
                            HStack(spacing: 12) {
                                // Option Icon
                                Image(systemName: option.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedIndex.wrappedValue == index ? .accentPurple : .themeSecondary)
                                    .frame(width: 32)
                                
                                // Option Title
                                Text(LocalizedStringKey(option.title))
                                    .font(.system(size: 16))
                                    .foregroundColor(.themePrimary)
                                
                                Spacer()
                                
                                // Checkmark
                                if selectedIndex.wrappedValue == index {
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
                        
                        if index < options.count - 1 {
                            Divider()
                                .background(Color.themeDivider)
                                .padding(.leading, 60)
                        }
                    }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
    }
    
    // MARK: - Action Card
    private func actionCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String?,
        showChevron: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                // Title & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themePrimary)
                    
                    if let subtitle = subtitle {
                        Text(LocalizedStringKey(subtitle))
                            .font(.system(size: 13))
                            .foregroundColor(.themeSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.themeTertiary)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct SettingsCard_Previews: PreviewProvider {
    @State static var isNotificationOn = true
    @State static var notificationHour = 9
    @State static var studyDirection = StudyDirection.enToTr
    @State static var themeMode = ThemeMode.system
    @State static var appLanguage = AppLanguage.english
    
    static var previews: some View {
        Group {
            ScrollView {
                VStack(spacing: 16) {
                    // Toggle Example
                    SettingsCard(
                        type: .notificationToggle(
                            isOn: $isNotificationOn,
                            selectedHour: $notificationHour,
                            onToggle: { print("Toggle: \(isNotificationOn)") },
                            onTimeChange: { hour in print("Time: \(hour)") }
                        )
                    )
                    
                    // Inline Selection Example - Study Direction
                    SettingsCard(
                        type: .studyDirectionSelection(
                            selectedDirection: $studyDirection,
                            onDirectionChange: { dir in print("Direction: \(dir)") }
                        )
                    )
                    
                    // Inline Selection Example - Theme
                    SettingsCard(
                        type: .themeSelection(
                            selectedTheme: $themeMode,
                            onThemeChange: { theme in print("Theme: \(theme)") }
                        )
                    )
                    
                    // Inline Selection Example - Language
                    SettingsCard(
                        type: .languageSelection(
                            selectedLanguage: $appLanguage,
                            onLanguageChange: { lang in print("Language: \(lang)") }
                        )
                    )
                }
                .padding(20)
            }
            .background(Color.themeBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            ScrollView {
                VStack(spacing: 16) {
                    SettingsCard(
                        type: .notificationToggle(
                            isOn: $isNotificationOn,
                            selectedHour: $notificationHour,
                            onToggle: { },
                            onTimeChange: { _ in }
                        )
                    )
                }
                .padding(20)
            }
            .background(Color.themeBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
