import SwiftUI

// MARK: - Home View
/// Premium Home Screen – Focused, Motivational, Production-Grade
struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPackageSelection = false
    @State private var animateHero = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    
                    headerSection
                    
                    heroSection
                    
                    statsSection
                    
                    actionSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Header
private extension HomeView {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("HocaLingo")
                .font(.system(size: 32, weight: .bold))
            
            Text(viewModel.greetingText)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Hero
private extension HomeView {
    
    var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.9),
                            Color.purple.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
            
            VStack(spacing: 20) {
                
                Button {
                    viewModel.startStudy()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 92, height: 92)
                            .shadow(color: .black.opacity(0.3), radius: 12, y: 6)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.blue)
                            .offset(x: 2)
                    }
                }
                .scaleEffect(animateHero ? 1 : 0.85)
                
                Text(viewModel.motivationText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 28)
        }
        .frame(height: 220)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateHero = true
            }
        }
    }
}

// MARK: - Stats
private extension HomeView {
    
    var statsSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.streakDays)",
                    label: "stat_streak_days",
                    accent: .orange
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.todaysWords)",
                    label: "stat_today_words",
                    accent: .green
                )
            }
            
            HStack(spacing: 14) {
                StatCard(
                    icon: "star.fill",
                    value: "\(viewModel.totalLearned)",
                    label: "stat_total_learned",
                    accent: .blue
                )
                
                Spacer()
            }
        }
    }
}

// MARK: - Actions
private extension HomeView {
    
    var actionSection: some View {
        VStack(spacing: 14) {
            ActionRow(
                icon: "square.grid.2x2.fill",
                title: "action_select_package",
                subtitle: "action_select_package_desc",
                tint: .purple
            ) {
                showPackageSelection = true
            }
            .sheet(isPresented: $showPackageSelection) {
                PackageSelectionView()
            }
            
            ActionRow(
                icon: "sparkles",
                title: "action_ai_assistant",
                subtitle: "action_ai_assistant_desc",
                tint: .cyan
            ) {
                // Navigate to AI assistant
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    
    let icon: String
    let value: String
    let label: String
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(accent)
            
            Text(value)
                .font(.system(size: 30, weight: .bold))
            
            Text(LocalizedStringKey(label))
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Action Row
struct ActionRow: View {
    
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(tint.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
