//
//  NotificationCard.swift
//  HocaLingo
//
//  Professional notification card with toggle and time picker
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
                        .foregroundColor(Color(hex: "6366F1"))
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings_notifications")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        if isEnabled {
                            Text("notification_scheduled")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
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
                
                Button(action: {
                    showTimePicker = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "6366F1").opacity(0.7))
                            .frame(width: 32)
                        
                        Text("notification_time_picker_title")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Display current time
                        Text(String(format: "%02d:00", notificationHour))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(hex: "6366F1"))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(
                selectedHour: $notificationHour,
                onConfirm: {
                    onTimeChange(notificationHour)
                    showTimePicker = false
                }
            )
        }
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedHour: Int
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Info Text
                Text("notification_time_picker_message")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
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
                        onConfirm()
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
        .background(Color.gray.opacity(0.1))
    }
}
