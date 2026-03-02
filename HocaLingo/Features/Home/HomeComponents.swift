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
                RoundedRectangle(cornerRadius: 30)
                    .fill(glowGradient)
                    .scaleEffect(heroBreathe)
                    .blur(radius: 16)
                    .opacity(0.6)

                RoundedRectangle(cornerRadius: 28)
                    .fill(cardGradient)

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

                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 10) {
                        streakBadge
                        Text(LocalizedStringKey("home_cta_title"))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        startPill
                    }
                    .padding(.leading, 20)
                    .padding(.vertical, 20)

                    Spacer()

                    rotatingContent
                        .padding(.trailing, 10)
                }
            }
            .frame(height: 158)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: shadowColor.opacity(0.45), radius: 22, y: 10)
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

    // MARK: - Sub-views
    private var streakBadge: some View {
        let streak = uiState.currentStreak
        return HStack(spacing: 5) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(streakFlameColor(for: streak))
            Text("\(streak)")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(streakBadgeBackground(for: streak))
        .clipShape(Capsule())
    }

    private var startPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "play.fill")
                .font(.system(size: 11, weight: .black))
            Text(LocalizedStringKey("home_start_btn"))
                .font(.system(size: 13, weight: .black, design: .rounded))
        }
        .foregroundColor(pillForeground)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.white.opacity(0.28), radius: 8, y: 3)
    }

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
                // FIX: LocalizedStringKey with string interpolation doesn't trigger
                // localization lookup at runtime. Pre-compute the key as String,
                // then use NSLocalizedString so the bundle lookup fires correctly.
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
        return LinearGradient(colors: [c.opacity(0.45), c.opacity(0.1)], startPoint: .top, endPoint: .bottom)
    }

    private var shadowColor: Color { isDark ? Color(hex: "9333EA") : Color(hex: "FB9322") }
    private var pillForeground: Color { isDark ? Color(hex: "7C3AED") : Color(hex: "E05F00") }

    private func streakFlameColor(for streak: Int) -> Color {
        switch streak {
        case 0:        return .white.opacity(0.6)
        case 1...4:    return Color(hex: "FCD34D")
        case 5...9:    return Color(hex: "FBBF24")
        case 10...14:  return Color(hex: "F59E0B")
        case 15...19:  return Color(hex: "F97316")
        case 20...29:  return Color(hex: "EF4444")
        default:       return Color(hex: "DC2626")
        }
    }

    private func streakBadgeBackground(for streak: Int) -> Color {
        switch streak {
        case 0:        return .white.opacity(0.15)
        case 1...4:    return .white.opacity(0.22)
        case 5...9:    return Color(hex: "FBBF24").opacity(0.25)
        case 10...14:  return Color(hex: "F59E0B").opacity(0.30)
        case 15...19:  return Color(hex: "F97316").opacity(0.35)
        case 20...29:  return Color(hex: "EF4444").opacity(0.35)
        default:       return Color(hex: "DC2626").opacity(0.40)
        }
    }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: STAT CARD
// MARK: ─────────────────────────────────────────────────────────

struct StatCardWithChart: View {
    let title: String
    let value: String
    var subtitle: String = ""
    let icon: String
    let gradient: [Color]
    let chartData: [Double]

    private var primaryColor: Color { gradient.first ?? .blue }

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

            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { i, point in
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
    }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: ACTION BUTTONS SECTION
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

            // ── PRIMARY: Package Selection — solid teal, single label ──
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
                .padding(.vertical, 18)
                .background(orange)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: orange.opacity(0.3), radius: 12, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            .frame(maxWidth: .infinity)

            // ── SECONDARY: Add Word — icon only, no text, no PNG ──────
            Button(action: onAddWord) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(teal)
                    .frame(width: 72, height: 72)
                    .background(Color.themeCard)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(teal.opacity(isDark ? 0.45 : 0.35), lineWidth: 1.8)
                    )
                    .shadow(color: teal.opacity(0.15), radius: 8, y: 3)
            }
            .buttonStyle(SpringButtonStyle())
        }
    }
}


// MARK: ─────────────────────────────────────────────────────────
// MARK: VAULT PREVIEW ROW
// MARK: ─────────────────────────────────────────────────────────

struct VaultPreviewRow: View {
    @ObservedObject var vaultVM: WordVaultViewModel
    let onShowAll: () -> Void
    let isDark: Bool

    private let accent = Color(hex: "4ECDC4")

    var body: some View {
        VStack(spacing: 10) {
            // Section header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "archivebox.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(accent)
                    Text(LocalizedStringKey("vault_section_title"))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }

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
