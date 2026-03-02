//
//  StoryCreatorSheet.swift
//  HocaLingo
//
//  Features/AIStory/Views/StoryCreatorSheet.swift
//  ✅ REDESIGNED: SF Symbols, compact layout, modern pill buttons
//  Location: HocaLingo/Features/AIStory/Views/StoryCreatorSheet.swift
//

import SwiftUI

/// Story Creator Sheet - Modern design form
struct StoryCreatorSheet: View {
    
    @ObservedObject var viewModel: AIStoryViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var showPaywall = false
    @FocusState private var isTopicFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.themeBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Scrollable content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Header
                            headerSection
                            
                            // Topic Input
                            topicSection
                            
                            // Type Selection
                            typeSection
                            
                            // Length Selection
                            lengthSection
                            
                            // Word count info
                            wordCountInfo
                            
                            // Quota Warning (if low)
                            if viewModel.uiState.quota.remaining <= 1 {
                                quotaWarning
                            }
                            
                            // Extra padding for button
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    
                    // Generate button at bottom (outside ScrollView)
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.themeSecondary.opacity(0.2))
                        
                        generateButton
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                    }
                    .background(Color.themeBackground)
                }
                
                // Insufficient words dialog overlay
                if viewModel.uiState.showInsufficientWords {
                    InsufficientWordsDialog(
                        required: viewModel.uiState.insufficientWordsRequired,
                        available: viewModel.uiState.insufficientWordsAvailable,
                        onDismiss: {
                            viewModel.uiState.showInsufficientWords = false
                        },
                        onAddWords: {
                            viewModel.uiState.showInsufficientWords = false
                            dismiss()
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationTitle("ai_story_creator_title")
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
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallView()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.accentPurple)
            
            Text("ai_story_creator_subtitle")
                .font(.system(size: 13))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Topic Input
    
    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text("ai_story_topic_label")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } icon: {
                Image(systemName: "pencil.line")
                    .font(.system(size: 12))
            }
            .foregroundColor(.themePrimary)
            
            TextField("", text: $viewModel.uiState.creatorTopic, prompt: Text("ai_story_topic_placeholder").foregroundColor(.themeSecondary.opacity(0.6)))
                .font(.system(size: 15))
                .foregroundColor(.themePrimary)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.themeCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.accentPurple.opacity(isTopicFocused ? 0.4 : 0.1), lineWidth: 1)
                        )
                )
                .focused($isTopicFocused)
            
            Text("ai_story_topic_hint")
                .font(.system(size: 11))
                .foregroundColor(.themeSecondary.opacity(0.7))
        }
    }
    
    // MARK: - Type Selection
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("ai_story_type_label")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } icon: {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 12))
            }
            .foregroundColor(.themePrimary)
            
            VStack(spacing: 8) {
                ForEach(StoryType.allCases) { type in
                    TypePillButton(
                        type: type,
                        isSelected: viewModel.uiState.creatorType == type,
                        isPremium: viewModel.uiState.isPremium
                    ) {
                        viewModel.handle(.selectType(type))
                    }
                }
            }
        }
    }
    
    // MARK: - Length Selection
    
    private var lengthSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("ai_story_length_label")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            } icon: {
                Image(systemName: "ruler")
                    .font(.system(size: 12))
            }
            .foregroundColor(.themePrimary)
            
            HStack(spacing: 10) {
                ForEach(StoryLength.allCases) { length in
                    LengthPillButton(
                        length: length,
                        isSelected: viewModel.uiState.creatorLength == length,
                        isPremium: viewModel.uiState.isPremium
                    ) {
                        viewModel.handle(.selectLength(length))
                    }
                }
            }
        }
    }
    
    // MARK: - Word Count Info
    
    private var wordCountInfo: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 13))
                .foregroundColor(.accentPurple.opacity(0.7))
            
            Text(String(format: NSLocalizedString("ai_story_word_info", comment: ""),
                 viewModel.uiState.creatorLength.exactDeckWords,
                 viewModel.uiState.allWords.count))
                .font(.system(size: 12))
                .foregroundColor(.themeSecondary)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentPurple.opacity(0.06))
        )
    }
    
    // MARK: - Quota Warning
    
    private var quotaWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14))
                .foregroundColor(.orange)
            
            Text(viewModel.uiState.isPremium
                 ? "ai_story_quota_warning_premium_\(viewModel.uiState.quota.remaining)"
                 : "ai_story_quota_warning_free_\(viewModel.uiState.quota.remaining)")
                .font(.system(size: 12))
                .foregroundColor(.themeSecondary)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.08))
        )
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button {
            isTopicFocused = false
            
            let selectedType = viewModel.uiState.creatorType
            let selectedLength = viewModel.uiState.creatorLength
            let requiresPremium = (selectedType == .fantasy) || (selectedLength == .long)
            
            if requiresPremium && !viewModel.uiState.isPremium {
                showPaywall = true
            } else if !viewModel.uiState.hasQuota {
                viewModel.handle(.generateStory)
            } else {
                viewModel.handle(.generateStory)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("ai_story_generate")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .shadow(color: Color(hex: "6366F1").opacity(0.35), radius: 10, y: 5)
        }
    }
}

// MARK: - Type Pill Button (Modernized)

struct TypePillButton: View {
    let type: StoryType
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    private var isLocked: Bool {
        (type == .fantasy) && !isPremium
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // SF Symbol icon in colored circle
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.2) : type.iconColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: type.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isSelected ? .white : type.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .themePrimary)
                }
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? LinearGradient(
                              colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                              startPoint: .leading,
                              endPoint: .trailing
                          )
                          : LinearGradient(
                              colors: [Color.themeCard, Color.themeCard],
                              startPoint: .leading,
                              endPoint: .trailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.accentPurple.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Length Pill Button (Modernized)

struct LengthPillButton: View {
    let length: StoryLength
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    private var isLocked: Bool {
        (length == .long) && !isPremium
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon
                Image(systemName: length.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .accentPurple)
                
                HStack(spacing: 3) {
                    Text(length.displayName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? .white : .themePrimary)
                    
                    if isLocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
                
                Text(length.estimatedReadTime)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.7) : .themeSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                          ? LinearGradient(
                              colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                              startPoint: .leading,
                              endPoint: .trailing
                          )
                          : LinearGradient(
                              colors: [Color.themeCard, Color.themeCard],
                              startPoint: .leading,
                              endPoint: .trailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.clear : Color.accentPurple.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    StoryCreatorSheet(viewModel: AIStoryViewModel())
}
