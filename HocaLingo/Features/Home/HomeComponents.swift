//
//  HomeComponents.swift
//  HocaLingo
//
//  All reusable UI components for HomeView.
//  Location: Features/Home/HomeComponents.swift
//

import SwiftUI
import Charts

// MARK: ─────────────────────────────────────────────────────────
// MARK: HERO CARD  (Floating Action Pulse)
// MARK: ─────────────────────────────────────────────────────────

struct HeroCardView: View {
    let uiState: HomeUiState
    let currentContentType: HeroContentType
    let heroBreathe: CGFloat
    let isDark: Bool
    let onTap: () -> Void

    @Environment(\.themeViewModel) private var themeViewModel
    @Environment(\.colorScheme) private var colorScheme
    // Triggers re-render when language changes → motivation text updates immediately
    @AppStorage("app_language") private var appLanguageCode: String = "en"

    @State private var particleOffsets: [CGSize] = Array(repeating: .zero, count: 5)
    @State private var particleOpacities: [Double] = Array(repeating: 0, count: 5)

    private let particleSpawns: [CGPoint] = [
        CGPoint(x: 40,  y: 100),
        CGPoint(x: 120, y: 130),
        CGPoint(x: 210, y: 90),
        CGPoint(x: 290, y: 115),
        CGPoint(x: 180, y: 140),
    ]

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Glow background (reduced intensity)
                RoundedRectangle(cornerRadius: 30)
                    .fill(glowGradient)
                    .scaleEffect(heroBreathe)
                    .blur(radius: 12)
                    .opacity(0.35)

                // Card gradient fill
                RoundedRectangle(cornerRadius: 28)
                    .fill(cardGradient)

                // Light sheen overlay
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                // Floating particles
                GeometryReader { _ in
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(particleOpacities[i]))
                            .frame(width: 6, height: 6)
                            .offset(
                                x: particleSpawns[i].x + particleOffsets[i].width,
                                y: particleSpawns[i].y + particleOffsets[i].height
                            )
                            .blur(radius: 1)
                    }
                }
                .allowsHitTesting(false)
                .clipped()

                // Content: Big play button (left) + rotating content (right)
                HStack(alignment: .center, spacing: 0) {
                    playButton
                        .padding(.leading, 16)

                    Spacer()

                    rotatingContent
                        .padding(.trailing, 8)
                }
            }
            .frame(height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: shadowColor.opacity(0.25), radius: 16, y: 8)
        }
        .buttonStyle(SpringButtonStyle())
        .onAppear { startParticleLoop() }
    }

    // MARK: - Particle Loop
    private func startParticleLoop() {
        for i in 0..<5 {
            animateParticle(i, delay: Double(i) * 0.55)
        }
    }

    private func animateParticle(_ i: Int, delay: Double) {
        let floatUp = CGFloat.random(in: -55 ... -30)
        let drift   = CGFloat.random(in: -12 ... 12)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            particleOffsets[i]   = .zero
            particleOpacities[i] = 0

            withAnimation(.easeOut(duration: 2.0)) {
                particleOffsets[i]   = CGSize(width: drift, height: floatUp)
                particleOpacities[i] = 0.55
            }
            withAnimation(.easeIn(duration: 0.8).delay(1.4)) {
                particleOpacities[i] = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                animateParticle(i, delay: 0)
            }
        }
    }

    private var playButton: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "4ADE80"))
                    .frame(width: 6, height: 6)
                    .shadow(color: Color(hex: "4ADE80").opacity(0.8), radius: 3)
                
                Text(LocalizedStringKey("home_ready_status"))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1.2)
                    .textCase(.uppercase)
            }
            
            // Tight spacing between status and number
            Spacer().frame(height: 4)
            
            // Big number — actual cards ready to study
            Text("\(uiState.wordsReadyToStudy)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            // Label directly below number
            Text(LocalizedStringKey("home_words_remaining"))
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
                .padding(.top, 2)
            
            // Push pill to bottom
            Spacer(minLength: 10)
            
            // Action hint pill
            HStack(spacing: 6) {
                Text(LocalizedStringKey("home_tap_to_continue"))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .frame(width: 155, height: 130, alignment: .leading)
        .padding(.leading, 4)
        .padding(.vertical, 10)
    }

    // MARK: - Rotating Content (mascot / motivation text)
    private var rotatingContent: some View {
        Group {
            switch currentContentType {
            case .image(let index):
                let mascots = ["lingohoca1", "lingohoca2", "lingohoca3", "lingohoca_celebrate", "lingohoca_nod", "lingohoca_nod"]
                Image(mascots[index % mascots.count])
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.30)

            case .text(let index):
                let key = "motivation_\(index + 1)"
                Text(NSLocalizedString(key, comment: ""))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .lineLimit(4)
            }
        }
        .frame(width: 160, height: 120)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.5), value: currentContentType)
    }

    // MARK: - Colors
    private var cardGradient: LinearGradient {
        isDark
            ? LinearGradient(colors: [Color(hex: "9333EA"), Color(hex: "7C3AED")], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color(hex: "FB9322"), Color(hex: "FF6B00")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var glowGradient: LinearGradient {
        let c = isDark ? Color(hex: "9333EA") : Color(hex: "FB9322")
        return LinearGradient(colors: [c.opacity(0.40), c.opacity(0.08)], startPoint: .top, endPoint: .bottom)
    }

    private var shadowColor: Color { isDark ? Color(hex: "9333EA") : Color(hex: "FB9322") }
    private var pillForeground: Color { isDark ? Color(hex: "7C3AED") : Color(hex: "E05F00") }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: STAT CARD (with touch feedback)
// MARK: ─────────────────────────────────────────────────────────

struct StatCardWithChart: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    let gradient: [Color]
    let chartData: [Double]

    private var primaryColor: Color { gradient.first ?? .blue }

    // Touch feedback state
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(primaryColor)
                    .frame(width: 22, height: 22)
                    .background(primaryColor.opacity(0.12))
                    .clipShape(Circle())
                Text(LocalizedStringKey(title))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(primaryColor)
                if !subtitle.isEmpty {
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(primaryColor.opacity(0.6))
                }
            }

            Spacer(minLength: 0)

            // Chart — safe for zero values (flat line)
            Chart {
                ForEach(Array(safeChartData.enumerated()), id: \.offset) { i, point in
                    AreaMark(x: .value("i", i), y: .value("v", point))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [primaryColor.opacity(0.38), primaryColor.opacity(0.01)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    LineMark(x: .value("i", i), y: .value("v", point))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(primaryColor)
                        .lineStyle(StrokeStyle(lineWidth: 2.2, lineCap: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 28)
        }
        .padding(11)
        .frame(maxWidth: .infinity)
        .background(primaryColor.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(primaryColor.opacity(0.2), lineWidth: 1.1))
        .frame(height: 115)
        // Touch feedback — spring scale like hero card
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    /// Prevents ugly descending chart when value is zero
    private var safeChartData: [Double] {
        let allZero = chartData.allSatisfy { $0 == 0 }
        if allZero {
            // Return tiny baseline so chart renders a flat line at bottom
            return Array(repeating: 0.01, count: chartData.count)
        }
        // Clamp negatives just in case
        return chartData.map { max($0, 0) }
    }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: ACTION BUTTONS SECTION (slightly shorter height)
// MARK: ─────────────────────────────────────────────────────────

struct HomeActionButtonsSection: View {
    let onPackageSelect: () -> Void
    let onAddWord: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel

    private var isDark: Bool { themeViewModel.isDarkMode(in: colorScheme) }
    private let teal   = Color.accentTeal
    private let orange = Color.accentOrange

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // ── PRIMARY: Package Selection — solid orange, single label ──
            Button(action: onPackageSelect) {
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text(LocalizedStringKey("action_select_package"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(orange)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: orange.opacity(0.25), radius: 10, y: 4)
            }
            .buttonStyle(ScaleButtonStyle())
            .frame(maxWidth: .infinity)

            // ── SECONDARY: Add Word — icon only ──────
            Button(action: onAddWord) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(teal)
                    .frame(width: 72, height: 62)
                    .background(Color.themeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(teal.opacity(isDark ? 0.45 : 0.35), lineWidth: 1.8)
                    )
                    .shadow(color: teal.opacity(0.12), radius: 6, y: 3)
            }
            .buttonStyle(SpringButtonStyle())
        }
    }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: VAULT PREVIEW ROW (tappable title)
// MARK: ─────────────────────────────────────────────────────────

struct VaultPreviewRow: View {
    @ObservedObject var vaultVM: WordVaultViewModel
    let onShowAll: () -> Void
    let isDark: Bool

    private let accent = Color(hex: "4ECDC4")

    var body: some View {
        VStack(spacing: 10) {
            // Section header — title is now tappable (same as "show all")
            HStack {
                Button(action: onShowAll) {
                    HStack(spacing: 6) {
                        Image(systemName: "archivebox.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(accent)
                        Text(LocalizedStringKey("vault_section_title"))
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                Button(action: onShowAll) {
                    HStack(spacing: 4) {
                        Text("\(vaultVM.totalCount)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(accent)
                        Text(LocalizedStringKey("vault_show_all"))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(accent)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(accent)
                    }
                }
            }

            if vaultVM.isLoading {
                HStack { Spacer(); ProgressView().scaleEffect(0.8); Spacer() }
                    .frame(height: 76)
            } else if vaultVM.previewWords.isEmpty {
                emptyPreview
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vaultVM.previewWords) { word in
                            VaultPreviewCard(word: word, isDark: isDark, accent: accent)
                        }

                        Button(action: onShowAll) {
                            VStack(spacing: 6) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(accent)
                                Text(LocalizedStringKey("vault_show_all"))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(accent)
                            }
                            .frame(width: 80, height: 76)
                            .background(accent.opacity(isDark ? 0.12 : 0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(accent.opacity(0.25), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }

    private var emptyPreview: some View {
        HStack {
            Image(systemName: "plus.circle")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            Text(LocalizedStringKey("vault_preview_empty"))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .frame(height: 76)
    }
}

// Small flip card in the preview row
struct VaultPreviewCard: View {
    let word: VaultWord
    let isDark: Bool
    let accent: Color

    @State private var isFlipped = false

    var body: some View {
        ZStack {
            // Back: Turkish
            RoundedRectangle(cornerRadius: 14)
                .fill(accent.opacity(isDark ? 0.2 : 0.12))
                .overlay(
                    Text(word.turkish)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(accent)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(8)
                )
                .opacity(isFlipped ? 1 : 0)

            // Front: English
            RoundedRectangle(cornerRadius: 14)
                .fill(isDark ? Color.white.opacity(0.07) : Color.white.opacity(0.85))
                .overlay(
                    Text(word.english)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(8)
                )
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(width: 80, height: 76)
        .shadow(color: .black.opacity(isDark ? 0.2 : 0.06), radius: 4, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}

// MARK: ─────────────────────────────────────────────────────────
// MARK: PLAY TRIANGLE SHAPE (Bezier-based, clean Apple-style)
// MARK: ─────────────────────────────────────────────────────────
 
/// A right-pointing play triangle with smooth rounded corners via quadratic bezier curves.
/// Much cleaner than arc-tangent approach — no distorted corners at sharp angles.
struct PlayTriangleShape: Shape {
    var cornerRadius: CGFloat = 10
 
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
 
        // Three vertices of the play triangle
        let p1 = CGPoint(x: width * 0.22, y: height * 0.12) // top-left
        let p2 = CGPoint(x: width * 0.82, y: height * 0.50) // right tip
        let p3 = CGPoint(x: width * 0.22, y: height * 0.88) // bottom-left
 
        let radius = min(cornerRadius, width * 0.12, height * 0.12)
 
        // Helper: point along edge at 'distance' from 'start' toward 'end'
        func point(from start: CGPoint, to end: CGPoint, distance: CGFloat) -> CGPoint {
            let dx = end.x - start.x
            let dy = end.y - start.y
            let length = sqrt(dx * dx + dy * dy)
            guard length > 0 else { return start }
            return CGPoint(
                x: start.x + dx / length * distance,
                y: start.y + dy / length * distance
            )
        }
 
        // Offset points around each vertex
        let p1a = point(from: p1, to: p2, distance: radius)
        let p1b = point(from: p1, to: p3, distance: radius)
 
        let p2a = point(from: p2, to: p3, distance: radius)
        let p2b = point(from: p2, to: p1, distance: radius)
 
        let p3a = point(from: p3, to: p1, distance: radius)
        let p3b = point(from: p3, to: p2, distance: radius)
 
        var path = Path()
 
        path.move(to: p1a)
 
        // Top-left → right tip
        path.addLine(to: p2b)
        path.addQuadCurve(to: p2a, control: p2)
 
        // Right tip → bottom-left
        path.addLine(to: p3b)
        path.addQuadCurve(to: p3a, control: p3)
 
        // Bottom-left → top-left
        path.addLine(to: p1b)
        path.addQuadCurve(to: p1a, control: p1)
 
        path.closeSubpath()
        return path
    }
}
 

// MARK: ─────────────────────────────────────────────────────────
// MARK: BUTTON STYLES
// MARK: ─────────────────────────────────────────────────────────

struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
