//
//  StoryCreatorSheet.swift
//  HocaLingo
//
//  Features/AIStory/Views/StoryCreatorSheet.swift
//  ✅ UPDATED: Integrated InsufficientWordsDialog
//

import SwiftUI

/// Story Creator Sheet - Premium design form
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
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerSection
                            
                            // Topic Input
                            topicSection
                            
                            // Type Selection
                            typeSection
                            
                            // Length Selection
                            lengthSection
                            
                            // Quota Warning (if low)
                            if viewModel.uiState.quota.remaining <= 1 {
                                quotaWarning
                            }
                            
                            // Extra padding for button
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    // ✅ Generate button at bottom (outside ScrollView)
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.themeSecondary.opacity(0.2))
                        
                        generateButton
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                    }
                    .background(Color.themeBackground)
                }
                
                // ✅ NEW: Insufficient words dialog overlay
                if viewModel.uiState.showInsufficientWords {
                    InsufficientWordsDialog(
                        required: viewModel.uiState.insufficientWordsRequired,
                        available: viewModel.uiState.insufficientWordsAvailable,
                        onDismiss: {
                            viewModel.uiState.showInsufficientWords = false
                        },
                        onAddWords: {
                            // Close dialog and creator sheet
                            viewModel.uiState.showInsufficientWords = false
                            dismiss()
                            // User will be navigated to package selection automatically
                        }
                    )
                    .transition(.opacity)
                    .zIndex(100)
                }
            }
            .navigationTitle("story_creator_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close") {
                        dismiss()
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
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.accentPurple)
            
            Text("story_creator_title")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Topic Section
    
    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("story_topic_placeholder")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.themePrimary)
            
            TextField(NSLocalizedString("story_topic_hint", comment: ""), text: Binding(
                get: { viewModel.uiState.creatorTopic },
                set: { viewModel.handle(.updateTopic($0)) }
            ))
            .focused($isTopicFocused)
            .textFieldStyle(.plain)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentPurple.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Type Section
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("select_type")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.themePrimary)
            
            VStack(spacing: 12) {
                ForEach(StoryType.allCases) { type in
                    TypePillButton(
                        type: type,
                        isSelected: viewModel.uiState.creatorType == type,
                        isPremium: viewModel.uiState.isPremium
                    ) {
                        // ✅ Premium check
                        let isLocked = (type == .fantasy) && !viewModel.uiState.isPremium
                        
                        if isLocked {
                            showPaywall = true
                        } else {
                            viewModel.handle(.selectType(type))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Length Section
    
    private var lengthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("select_length")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.themePrimary)
            
            HStack(spacing: 12) {
                ForEach(StoryLength.allCases) { length in
                    LengthPillButton(
                        length: length,
                        isSelected: viewModel.uiState.creatorLength == length,
                        isPremium: viewModel.uiState.isPremium
                    ) {
                        // ✅ Premium check
                        let isLocked = (length == .long) && !viewModel.uiState.isPremium
                        
                        if isLocked {
                            showPaywall = true
                        } else {
                            viewModel.handle(.selectLength(length))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quota Warning
    
    private var quotaWarning: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(viewModel.uiState.isPremium
                 ? "Son \(viewModel.uiState.quota.remaining) hakkınız kaldı"
                 : "Son \(viewModel.uiState.quota.remaining) hakkınız kaldı. Premium ile 30 hikaye yazın!")
                .font(.system(size: 13))
                .foregroundColor(.themeSecondary)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
        )
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button {
            // Dismiss keyboard first
            isTopicFocused = false
            
            // ✅ Premium check
            let selectedType = viewModel.uiState.creatorType
            let selectedLength = viewModel.uiState.creatorLength
            let requiresPremium = (selectedType == .fantasy) || (selectedLength == .long)
            
            if requiresPremium && !viewModel.uiState.isPremium {
                showPaywall = true
            } else if !viewModel.uiState.hasQuota {
                // No quota - error will be shown
                viewModel.handle(.generateStory)
            } else {
                // Generate story (insufficient words check happens in ViewModel)
                viewModel.handle(.generateStory)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("generate_button")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(hex: "6366F1").opacity(0.4), radius: 12, y: 6)
        }
    }
}

// MARK: - Type Pill Button

struct TypePillButton: View {
    let type: StoryType
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    private var isLocked: Bool {
        (type == .fantasy) && !isPremium
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(type.icon)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .themePrimary)
                }
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.accentPurple.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Length Pill Button

struct LengthPillButton: View {
    let length: StoryLength
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    private var isLocked: Bool {
        (length == .long) && !isPremium
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text(length.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .themePrimary)
                    
                    if isLocked {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                    }
                }
                
                Text("\(length.minDeckWords)-\(length.maxDeckWords) words")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .themeSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.accentPurple.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    StoryCreatorSheet(viewModel: AIStoryViewModel())
}
