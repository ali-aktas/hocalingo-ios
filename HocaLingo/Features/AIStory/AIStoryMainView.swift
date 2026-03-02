//
//  AIStoryMainView.swift
//  HocaLingo
//
//  Features/AIStory/AIStoryMainView.swift
//  ✅ REDESIGNED: Modern AI-themed UI, no emojis, Lottie, compact layout
//  Location: HocaLingo/Features/AIStory/AIStoryMainView.swift
//

import SwiftUI
import Lottie

/// AI Story Main Screen - Complete modern redesign
struct AIStoryMainView: View {
    
    @StateObject private var viewModel = AIStoryViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundLayer
            
            // Main content
            if viewModel.uiState.isLoading {
                loadingView
            } else {
                mainContent
            }
            
            // Generating overlay
            if viewModel.uiState.isGenerating {
                GeneratingView(viewModel: viewModel)
            }
        }
        .navigationTitle(Text("ai_story_title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.uiState.showCreator) {
            StoryCreatorSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.uiState.showHistory) {
            StoryHistorySheet(viewModel: viewModel)
        }
        .sheet(item: Binding(
            get: { viewModel.uiState.showDetail ? viewModel.uiState.currentStory : nil },
            set: { _ in viewModel.handle(.closeDetail) }
        )) { story in
            StoryDetailView(story: story, viewModel: viewModel)
        }
        .alert(item: Binding(
            get: { viewModel.uiState.error },
            set: { _ in viewModel.uiState.error = nil }
        )) { error in
            Alert(
                title: Text("ai_story_error_title"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("ok_button"))
            )
        }
        .onAppear {
            viewModel.handle(.loadData)
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [
                    Color(hex: "0F0B1A"),
                    Color(hex: "1A1128")
                ] : [
                    Color(hex: "F8F4FF"),
                    Color(hex: "F0E8FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle glow
            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.12 : 0.06))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: 80, y: -180)
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header with Lottie
                headerSection
                
                // Stats Row (Quota + History)
                statsRow
                
                // Recent Stories
                if !viewModel.uiState.stories.isEmpty {
                    recentStoriesSection
                }
                
                // Bottom spacing for floating button
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .overlay(
            // Floating Create Button
            VStack {
                Spacer()
                createButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
            }
        )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                // Sparkle ambient Lottie behind mascot
                LottieView(
                    animationName: "sparkle_ambient",
                    loopMode: .loop,
                    animationSpeed: 0.4
                )
                .frame(width: 200, height: 160)
                .opacity(0.5)
                .allowsHitTesting(false)
                
                // Mascot image
                Image("lingo_ai_header")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 110)
            }
            
            Text("ai_story_title")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
            
            Text("ai_story_subtitle")
                .font(.system(size: 13))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 12) {
            quotaCard
            historyCard
        }
    }
    
    private var quotaCard: some View {
        Button {
            if !viewModel.uiState.hasQuota {
                // Premium paywall
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.accentPurple)
                    
                    Text("ai_story_quota")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.themeSecondary)
                    
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(viewModel.uiState.quota.remaining)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.accentPurple)
                    
                    Text("/ \(viewModel.uiState.quota.limit)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.themeSecondary)
                }
                
                Text(viewModel.uiState.isPremium ? "ai_story_quota_premium" : "ai_story_quota_free")
                    .font(.system(size: 11))
                    .foregroundColor(.themeSecondary)
                    .lineLimit(1)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDarkMode ? Color(hex: "1E1730") : .white)
                    .shadow(color: .black.opacity(isDarkMode ? 0.3 : 0.06), radius: 8, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var historyCard: some View {
        Button {
            viewModel.handle(.openHistory)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("ai_story_history")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.themeSecondary)
                    
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(viewModel.uiState.stories.count)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "F59E0B"))
                    
                    Text("ai_story_stories")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.themeSecondary)
                }
                
                Text("ai_story_tap_to_browse")
                    .font(.system(size: 11))
                    .foregroundColor(.themeSecondary)
                    .lineLimit(1)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDarkMode ? Color(hex: "1E1730") : .white)
                    .shadow(color: .black.opacity(isDarkMode ? 0.3 : 0.06), radius: 8, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Recent Stories Section
    
    private var recentStoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ai_story_recent")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
            
            ForEach(Array(viewModel.uiState.stories.prefix(3))) { story in
                StoryRowCard(story: story) {
                    viewModel.handle(.openDetail(story))
                }
            }
        }
    }
    
    // MARK: - Create Button
    
    private var createButton: some View {
        Button {
            viewModel.handle(.openCreator)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("ai_story_create")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: viewModel.uiState.hasQuota
                        ? [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
                        : [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(
                color: viewModel.uiState.hasQuota
                    ? Color(hex: "6366F1").opacity(0.35)
                    : Color.clear,
                radius: 10, y: 5
            )
        }
        .disabled(!viewModel.uiState.hasQuota)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.3)
            Text("ai_story_loading")
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Story Row Card (Modernized)

struct StoryRowCard: View {
    let story: GeneratedStory
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Type icon (SF Symbol in colored circle)
                ZStack {
                    Circle()
                        .fill(story.type.iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: story.type.iconName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(story.type.iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                        .lineLimit(1)
                    
                    Text(story.preview)
                        .font(.system(size: 12))
                        .foregroundColor(.themeSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        // Length badge
                        HStack(spacing: 3) {
                            Image(systemName: story.length.iconName)
                                .font(.system(size: 9))
                            Text(story.length.displayName)
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.themeSecondary)
                        
                        // Favorite indicator
                        if story.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.red)
                        }
                        
                        // Word count badge
                        HStack(spacing: 2) {
                            Image(systemName: "textformat.abc")
                                .font(.system(size: 9))
                            Text("\(story.usedWords.count)")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.accentPurple.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.themeTertiary)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isDarkMode ? Color(hex: "1E1730") : .white)
                    .shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.06), radius: 6, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Story History Sheet (Modernized)

struct StoryHistorySheet: View {
    @ObservedObject var viewModel: AIStoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.uiState.stories.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 40))
                            .foregroundColor(.themeSecondary.opacity(0.5))
                        Text("ai_story_no_stories")
                            .font(.system(size: 15))
                            .foregroundColor(.themeSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.uiState.stories) { story in
                            StoryRowCard(story: story) {
                                viewModel.handle(.openDetail(story))
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.themeBackground)
            .navigationTitle("ai_story_history_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.themeSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - AIStoryError Identifiable

extension AIStoryError: Identifiable {
    var id: String {
        errorDescription ?? "unknown"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AIStoryMainView()
    }
}
