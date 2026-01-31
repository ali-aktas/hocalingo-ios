//
//  StoryCreatorSheet.swift
//  HocaLingo
//
//  Features/AIStory/Views/StoryCreatorSheet.swift
//  Premium design story creation form
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
                        
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Generate Button (Fixed at bottom, keyboard-aware)
                VStack {
                    Spacer()
                    generateButton
                        .padding(.bottom, 40)
                        .padding(.horizontal, 20)
                }
                .ignoresSafeArea(.keyboard)
            }
            .navigationTitle("story_creator_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                    .foregroundColor(.themeSecondary)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Bitti") {
                            isTopicFocused = false
                        }
                        .foregroundColor(.themePrimaryButton)
                    }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PremiumPaywallView()
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("🤖")
                .font(.system(size: 48))
            
            Text("Yapay zeka ile öğrendiğin kelimelerden hikaye oluştur")
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
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
                        // Check if requires premium
                        if type == .fantasy && !viewModel.uiState.isPremium {
                            showPaywall = true
                        } else {
                            viewModel.handle(.selectType(type))
                        }
                    }
                }
            }
        }
    }
    
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
                        // Check if requires premium
                        if length == .long && !viewModel.uiState.isPremium {
                            showPaywall = true
                        } else {
                            viewModel.handle(.selectLength(length))
                        }
                    }
                }
            }
        }
    }
    
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
    
    private var generateButton: some View {
        Button {
            // Dismiss keyboard first
            isTopicFocused = false
            
            // Check if selected options require premium
            let requiresPremium = viewModel.uiState.creatorType == .fantasy ||
                                  viewModel.uiState.creatorLength == .long
            
            if requiresPremium && !viewModel.uiState.isPremium {
                // Show paywall
                showPaywall = true
            } else if !viewModel.uiState.hasQuota {
                // No quota - will be handled by alert in main view
                viewModel.handle(.generateStory)
            } else {
                // Generate story
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
    
    // Premium check for this specific type
    private var requiresPremium: Bool {
        type == .fantasy
    }
    
    private var isLocked: Bool {
        requiresPremium && !isPremium
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
                    
                    if requiresPremium && !isPremium {
                        Text("Premium")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .themeSecondary)
                    }
                }
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .white.opacity(0.6) : .themeSecondary)
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
                    .stroke(
                        isSelected ? Color.clear : Color.accentPurple.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "6366F1").opacity(0.3) : Color.clear,
                radius: 8,
                y: 4
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
    
    // Premium check for this specific length
    private var requiresPremium: Bool {
        length == .long
    }
    
    private var isLocked: Bool {
        requiresPremium && !isPremium
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Lock icon (if locked)
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .white.opacity(0.6) : .themeSecondary)
                }
                
                Text(length.icon)
                    .font(.system(size: 32))
                
                Text(length.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .themePrimary)
                
                Text("\(length.targetWordCount) kelime")
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .themeSecondary)
                
                if requiresPremium && !isPremium {
                    Text("Premium")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color(hex: "FFD700"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : Color(hex: "FFD700").opacity(0.2))
                        )
                } else {
                    Text(length.estimatedReadTime)
                        .font(.system(size: 11))
                        .foregroundColor(isSelected ? .white.opacity(0.6) : .themeSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                          ? LinearGradient(
                              colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          )
                          : LinearGradient(
                              colors: [Color.themeCard, Color.themeCard],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.clear : Color.accentPurple.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: "6366F1").opacity(0.3) : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
