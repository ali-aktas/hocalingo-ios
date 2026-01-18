//
//  WordSelectionComponents.swift
//  HocaLingo
//
//  ✅ Action button component
//  Location: HocaLingo/Features/Selection/WordSelectionComponents.swift
//

import SwiftUI

// MARK: - Selection Action Button
struct SelectionActionButton: View {
    let icon: String
    let backgroundColor: Color
    let size: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    init(
        icon: String,
        backgroundColor: Color,
        size: CGFloat = 72,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        }) {
            ZStack {
                if isEnabled {
                    Circle()
                        .fill(backgroundColor.opacity(0.3))
                        .blur(radius: 8)
                        .offset(y: 4)
                }
                
                Circle()
                    .fill(isEnabled ? backgroundColor : backgroundColor.opacity(0.5))
                    .shadow(
                        color: .black.opacity(isEnabled ? 0.25 : 0.1),
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
    }
}

// MARK: - Preview
struct WordSelectionComponents_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 40) {
                HStack(spacing: 32) {
                    SelectionActionButton(
                        icon: "xmark",
                        backgroundColor: Color(hex: "EF5350"),
                        size: 72
                    ) {
                        print("Skip")
                    }
                    
                    SelectionActionButton(
                        icon: "checkmark",
                        backgroundColor: Color(hex: "66BB6A"),
                        size: 72
                    ) {
                        print("Learn")
                    }
                }
                
                SelectionActionButton(
                    icon: "arrow.uturn.backward",
                    backgroundColor: Color(hex: "9E9E9E"),
                    size: 56
                ) {
                    print("Undo")
                }
            }
        }
    }
}
