//
//  NotificationCard.swift
//  HocaLingo
//
//  ✅ UPDATED: Added dark theme support for notification card
//  Location: HocaLingo/Features/Profile/Components/NotificationCard.swift
//

import SwiftUI

// MARK: - Notification Card
struct NotificationCard: View {
    @Binding var isEnabled: Bool
    @Binding var notificationHour: Int
    let onToggle: () -> Void
    let onTimeChange: (Int) -> Void
    
    @State private var showTimePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Toggle
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentPurple)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings_notifications")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.themePrimary)
                        
                        if isEnabled {
                            Text(formattedNotificationTime)
                                .font(.system(size: 13))
                                .foregroundColor(.themeSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .onChange(of: isEnabled) { _ in
                        onToggle()
                    }
            }
            .padding(16)
            
            // Time Picker (shown when enabled)
            if isEnabled {
                Divider()
                    .background(Color.themeDivider)
                
                Button(action: {
                    showTimePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 18))
                            .foregroundColor(.themeSecondary)
                            .frame(width: 32)
                        
                        Text("Bildirim Saati")
                            .font(.system(size: 15))
                            .foregroundColor(.themePrimary)
                        
                        Spacer()
                        
                        Text(String(format: "%02d:00", notificationHour))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.accentPurple)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.themeSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.themeShadow, radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showTimePicker) {
            NotificationTimePickerSheet(
                selectedHour: notificationHour,
                onConfirm: { newHour in
                    notificationHour = newHour
                    onTimeChange(newHour)
                    showTimePicker = false
                }
            )
        }
    }
    
    private var formattedNotificationTime: String {
        String(format: "%02d:00", notificationHour)
    }
}

// MARK: - Notification Time Picker Sheet
struct NotificationTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var selectedHour: Int
    let onConfirm: (Int) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("notification_time_picker_message")
                    .font(.system(size: 15))
                    .foregroundColor(.themeSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // Hour Picker (0-23)
                Picker("Hour", selection: $selectedHour) {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d:00", hour))
                            .font(.system(size: 18))
                            .tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 200)
                
                Spacer()
            }
            .background(Color.themeBackground)
            .navigationTitle("notification_time_picker_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onConfirm(selectedHour)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview
struct NotificationCard_Previews: PreviewProvider {
    @State static var isEnabled = true
    @State static var hour = 12
    
    static var previews: some View {
        Group {
            VStack(spacing: 20) {
                NotificationCard(
                    isEnabled: $isEnabled,
                    notificationHour: $hour,
                    onToggle: {
                        print("Toggle: \(isEnabled)")
                    },
                    onTimeChange: { newHour in
                        print("Time changed to: \(newHour):00")
                    }
                )
                .padding()
            }
            .background(Color.themeBackground)
            .preferredColorScheme(.light)
            .previewDisplayName("Light Theme")
            
            VStack(spacing: 20) {
                NotificationCard(
                    isEnabled: $isEnabled,
                    notificationHour: $hour,
                    onToggle: {
                        print("Toggle: \(isEnabled)")
                    },
                    onTimeChange: { newHour in
                        print("Time changed to: \(newHour):00")
                    }
                )
                .padding()
            }
            .background(Color.themeBackground)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Theme")
        }
    }
}
