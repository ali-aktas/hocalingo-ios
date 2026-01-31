//
//  AIStoryMainView.swift
//  HocaLingo
//
//  Features/AIStory/AIStoryMainView.swift
//  AI Story Generation - Main Screen (COMPLETE VERSION)
//

import SwiftUI

/// AI Story Main Screen - Complete with ViewModel integration
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
        .navigationTitle("AI Hikaye Asistanı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.themeSecondary)
                        .font(.title3)
                }
            }
        }
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
                title: Text("error"),
                message: Text(error.errorDescription ?? "Bilinmeyen hata"),
                dismissButton: .default(Text("Tamam"))
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
                    Color(hex: "1A1625"),
                    Color(hex: "211A2E")
                ] : [
                    Color(hex: "FBF2FF"),
                    Color(hex: "FAF1FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glow effect
            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 400, height: 400)
                .blur(radius: 60)
                .offset(x: 100, y: -200)
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Cards Row
                HStack(spacing: 16) {
                    quotaCard
                    historyCard
                }
                
                // Recent Stories
                if !viewModel.uiState.stories.isEmpty {
                    recentStoriesSection
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .overlay(
            // Floating Create Button
            VStack {
                Spacer()
                createButton
                    .padding(.bottom, 40)
                    .padding(.horizontal, 20)
            }
        )
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image("lingo_ai_header")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            
            Text("AI Hikaye Asistanı")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.themePrimary)
            
            Text("Yapay zeka ile öğrendiğin kelimelerden hikayeler oluştur")
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    private var quotaCard: some View {
        Button {
            if !viewModel.uiState.hasQuota {
                // TODO: Show premium sheet
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.accentPurple)
                    Text("quota_remaining")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.themePrimary)
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.uiState.quota.remaining)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.accentPurple)
                    
                    Text("/ \(viewModel.uiState.quota.limit)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.themeSecondary)
                }
                
                Text(viewModel.uiState.isPremium ? "Premium - 30/ay" : "Free - 3/ay")
                    .font(.system(size: 11))
                    .foregroundColor(.themeSecondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDarkMode ? Color(hex: "2A2438") : .white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var historyCard: some View {
        Button {
            viewModel.handle(.openHistory)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(.orange)
                    Text("Hikayeler")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.themePrimary)
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(viewModel.uiState.stories.count)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("hikaye")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.themeSecondary)
                }
                
                Text("stories_this_month")
                    .font(.system(size: 11))
                    .foregroundColor(.themeSecondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isDarkMode ? Color(hex: "2A2438") : .white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var recentStoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Son Hikayeler")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.themePrimary)
            
            ForEach(Array(viewModel.uiState.stories.prefix(3))) { story in
                StoryRowCard(story: story) {
                    viewModel.handle(.openDetail(story))
                }
            }
        }
    }
    
    private var createButton: some View {
        Button {
            viewModel.handle(.openCreator)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("create_story")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: viewModel.uiState.hasQuota
                        ? [Color(hex: "6366F1"), Color(hex: "8B5CF6")]
                        : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(
                color: viewModel.uiState.hasQuota
                    ? Color(hex: "6366F1").opacity(0.4)
                    : Color.clear,
                radius: 12,
                y: 6
            )
        }
        .disabled(!viewModel.uiState.hasQuota)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("loading")
                .foregroundColor(.themeSecondary)
        }
    }
    
    // MARK: - Helpers
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Story Row Card

struct StoryRowCard: View {
    let story: GeneratedStory
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Type icon
                Text(story.type.icon)
                    .font(.system(size: 36))
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(story.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.themePrimary)
                        .lineLimit(1)
                    
                    Text(story.preview)
                        .font(.system(size: 13))
                        .foregroundColor(.themeSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(story.length.displayName, systemImage: story.length.icon)
                            .font(.system(size: 11))
                            .foregroundColor(.themeSecondary)
                        
                        if story.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.themeSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDarkMode ? Color(hex: "2A2438") : .white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Story History Sheet

struct StoryHistorySheet: View {
    @ObservedObject var viewModel: AIStoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.uiState.stories) { story in
                    Button {
                        viewModel.handle(.openDetail(story))
                    } label: {
                        StoryRowCard(story: story) {
                            viewModel.handle(.openDetail(story))
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .background(Color.themeBackground)
            .navigationTitle("story_history")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close") {
                        dismiss()
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
