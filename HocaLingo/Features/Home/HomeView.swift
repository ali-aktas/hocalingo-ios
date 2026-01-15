import SwiftUI

// MARK: - Home View
/// Main home screen with user stats, motivation, and play button
/// Location: HocaLingo/Features/Home/HomeView.swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPackageSelection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Greeting Section
                    greetingSection
                    
                    // Hero Card (Play Button + Motivation)
                    heroCard
                    
                    // Stats Section
                    statsSection
                    
                    // Action Buttons
                    actionButtons
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("HocaLingo")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(viewModel.greetingText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Hero Card
    private var heroCard: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)
            
            VStack(spacing: 12) {
                // Play Button
                Button(action: {
                    viewModel.startStudy()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Motivation Text
                Text(viewModel.motivationText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 12) {
            // Row 1: Streak + Today's Words
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.streakDays)",
                    label: "stat_streak_days",
                    color: .orange
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.todaysWords)",
                    label: "stat_today_words",
                    color: .green
                )
            }
            
            // Row 2: Total Learned
            HStack(spacing: 12) {
                StatCard(
                    icon: "star.fill",
                    value: "\(viewModel.totalLearned)",
                    label: "stat_total_learned",
                    color: .blue
                )
                
                // Placeholder for balance
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            ActionButton(
                icon: "square.grid.2x2.fill",
                title: "action_select_package",
                subtitle: "action_select_package_desc",
                color: .purple
            ) {
                showPackageSelection = true
            }
            .sheet(isPresented: $showPackageSelection) {
                PackageSelectionView()
            }
            
            ActionButton(
                icon: "sparkles",
                title: "action_ai_assistant",
                subtitle: "action_ai_assistant_desc",
                color: .cyan
            ) {
                // TODO: Navigate to AI assistant
            }
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(LocalizedStringKey(label))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Action Button Component
struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(title))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(LocalizedStringKey(subtitle))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
