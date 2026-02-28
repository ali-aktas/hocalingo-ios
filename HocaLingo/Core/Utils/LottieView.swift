//
//  LottieView.swift
//  HocaLingo
//
//  SwiftUI wrapper for Lottie animations
//  Requires: lottie-ios SPM package (https://github.com/airbnb/lottie-ios)
//  Location: HocaLingo/Core/Utils/LottieView.swift
//

import SwiftUI
import Lottie

// MARK: - Lottie View
struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    func makeUIView(context: Context) -> some UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .clear

        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        animationView.play()

        return container
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No dynamic updates needed
    }
}

// MARK: - Preview
#Preview {
    LottieView(animationName: "confetti_minimal", loopMode: .loop)
        .frame(width: 200, height: 200)
}
