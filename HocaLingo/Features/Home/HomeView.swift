//
//  HomeView.swift
//  HocaLingo
//
//  Premium Home Screen - COMPLETE REDESIGN matching Android
//  Location: HocaLingo/Features/Home/HomeView.swift
//

import SwiftUI

// MARK: - Home View
/// Premium Home Dashboard - Production-grade with Android parity
struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showPackageSelection = false
    @State private var showAIAssistant = false
    @State private var animateHero = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.uiState.isLoading {
                    ProgressView("Loading...")
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            // 1. Header with greeting
                            headerSection
                            
                            // 2. Hero card with Play button
                            heroCard
                            
                            // 3. Daily goal progress
                            dailyGoalSection
                            
                            // 4. Stats cards (3x grid)
                            statsGrid
                            
                            // 5. Action buttons
                            actionButtonsSection
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 100) // Space for bottom nav
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPackageSelection) {
            PackageSelectionView()
        }
        .sheet(isPresented: $showAIAssistant) {
            // AI Assistant placeholder
            Text("AI Assistant - Coming Soon!")
                .font(.title)
                .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateHero = true
            }
        }
    }
}

// MARK: - Header Section
private extension HomeView {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // HocaLingo title
            HStack {
                Text("HocaLingo")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Premium badge (if premium)
                if viewModel.uiState.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                        Text("Premium")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "FFD700"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FFD700").opacity(0.2), Color(hex: "FFA500").opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            
            // Greeting
            Text(viewModel.greetingText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Hero Card
private extension HomeView {
    
    var heroCard: some View {
        ZStack {
            // Gradient background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "431F84"), // Main purple from Android
                            Color(hex: "6B3FA0")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "431F84").opacity(0.3), radius: 20, y: 10)
            
            VStack(spacing: 20) {
                
                // Play button
                Button {
                    viewModel.onEvent(.startStudy)
                } label: {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 88, height: 88)
                            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "FB9322")) // Android orange
                            .offset(x: 3)
                    }
                }
                .scaleEffect(animateHero ? 1.0 : 0.8)
                
                // Motivation text
                Text(viewModel.motivationText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(animateHero ? 1.0 : 0.0)
                
                // Streak indicator
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "FB9322"))
                    
                    Text("\(viewModel.uiState.streakDays) day streak")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.vertical, 32)
        }
        .frame(height: 240)
    }
}

// MARK: - Daily Goal Section
private extension HomeView {
    
    var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            HStack {
                Text("Today's Goal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Progress text
                Text("\(viewModel.uiState.dailyGoalProgress.currentWords)/\(viewModel.uiState.dailyGoalProgress.targetWords)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * viewModel.uiState.dailyGoalProgress.progress,
                            height: 12
                        )
                }
            }
            .frame(height: 12)
            
            // Motivational text
            if viewModel.uiState.dailyGoalProgress.isCompleted {
                Text("🎉 Goal completed! Amazing work!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "4ECDC4"))
            } else {
                Text("\(viewModel.uiState.dailyGoalProgress.remainingWords) more words to reach your goal")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Stats Grid
private extension HomeView {
    
    var statsGrid: some View {
        VStack(spacing: 12) {
            // Row 1: Streak + Today's words
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.uiState.streakDays)",
                    label: "Day Streak",
                    color: Color(hex: "FF6B6B"),
                    isSmall: false
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.uiState.dailyGoalProgress.currentWords)",
                    label: "Today",
                    color: Color(hex: "4ECDC4"),
                    isSmall: false
                )
            }
            
            // Row 2: Total learned
            StatCard(
                icon: "star.fill",
                value: "\(UserDefaultsManager.shared.loadUserStats().wordsLearned)",
                label: "Total Learned",
                color: Color(hex: "FFD93D"),
                isSmall: false
            )
        }
    }
}

// MARK: - Action Buttons
private extension HomeView {
    
    var actionButtonsSection: some View {
        VStack(spacing: 14) {
            // Section title
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Package Selection button
            ActionButton(
                icon: "square.grid.2x2.fill",
                title: "Browse Word Packages",
                subtitle: "Add new words to study",
                color: Color(hex: "4ECDC4"),
                action: {
                    showPackageSelection = true
                }
            )
            
            // AI Assistant button
            ActionButton(
                icon: "sparkles",
                title: "AI Assistant",
                subtitle: "Practice with AI stories",
                color: Color(hex: "BB8FCE"),
                action: {
                    showAIAssistant = true
                }
            )
            
            // Premium button (if not premium)
            if !viewModel.uiState.isPremium {
                ActionButton(
                    icon: "crown.fill",
                    title: "Upgrade to Premium",
                    subtitle: "Unlock all features",
                    color: Color(hex: "FFD700"),
                    action: {
                        // TODO: Show premium screen
                        print("Show premium")
                    }
                )
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
    let isSmall: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: isSmall ? 20 : 24))
                .foregroundColor(color)
            
            // Value
            Text(value)
                .font(.system(size: isSmall ? 24 : 28, weight: .bold))
                .foregroundColor(.primary)
            
            // Label
            Text(label)
                .font(.system(size: isSmall ? 12 : 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isSmall ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
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
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.secondary.opacity(0.6))
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.15), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
