import SwiftUI

// MARK: - Word Selection Components
/// Clean and minimal UI components for Word Selection feature
/// Components: ActionButton (large), SmallActionButton, ProcessingIndicator, CompletionView
/// Location: HocaLingo/Features/WordSelection/WordSelectionComponents.swift

// MARK: - Selection Action Button (Large)
/// Large circular button for main actions (Skip, Learn)
struct SelectionActionButton: View {
    let icon: String // SF Symbol name
    let backgroundColor: Color
    let size: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(icon: String, backgroundColor: Color, size: CGFloat = 80, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
                    .shadow(color: backgroundColor.opacity(0.4), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 2 : 4)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Selection Small Button
/// Small circular button for secondary actions (Home, Undo)
struct SelectionSmallButton: View {
    let icon: String // SF Symbol name
    let backgroundColor: Color
    let size: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(icon: String, backgroundColor: Color, size: CGFloat = 56, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
                    .shadow(color: backgroundColor.opacity(0.3), radius: isPressed ? 3 : 6, x: 0, y: isPressed ? 1 : 3)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Processing Indicator
/// Minimal loading indicator shown during card transition
struct ProcessingIndicator: View {
    let isProcessing: Bool
    
    var body: some View {
        Group {
            if isProcessing {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("İşleniyor...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
}

// MARK: - Completion View
/// Clean completion view shown when all words are processed
struct CompletionView: View {
    let selectedCount: Int
    let hiddenCount: Int
    let onContinue: () -> Void
    let onGoHome: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color(hex: "66BB6A").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "66BB6A"))
            }
            
            // Title
            Text("Tebrikler! 🎉")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            // Stats
            VStack(spacing: 12) {
                StatRow(
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "66BB6A"),
                    label: "Seçilen kelimeler",
                    value: "\(selectedCount)"
                )
                StatRow(
                    icon: "xmark.circle.fill",
                    color: Color(hex: "EF5350"),
                    label: "Geçilen kelimeler",
                    value: "\(hiddenCount)"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
                .frame(height: 40)
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                        Text("Öğrenmeye Başla")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "66BB6A"))
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onGoHome) {
                    Text("Ana Sayfaya Dön")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Stat Row
/// Single stat row for completion view
struct StatRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
#Preview("Action Buttons") {
    VStack(spacing: 24) {
        HStack(spacing: 32) {
            SelectionSmallButton(icon: "house.fill", backgroundColor: Color(hex: "FF851B")) {
                print("Home tapped")
            }
            
            SelectionActionButton(icon: "xmark", backgroundColor: Color(hex: "EF5350")) {
                print("Skip tapped")
            }
            
            SelectionActionButton(icon: "checkmark", backgroundColor: Color(hex: "66BB6A")) {
                print("Learn tapped")
            }
            
            SelectionSmallButton(icon: "arrow.uturn.backward", backgroundColor: Color(hex: "2196F3")) {
                print("Undo tapped")
            }
        }
    }
    .padding()
}

#Preview("Completion View") {
    CompletionView(
        selectedCount: 25,
        hiddenCount: 8,
        onContinue: { print("Continue tapped") },
        onGoHome: { print("Go home tapped") }
    )
}
