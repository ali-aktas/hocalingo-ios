//
//  StoryDetailView.swift
//  HocaLingo
//
//  Features/AIStory/Views/StoryDetailView.swift
//  ✅ REDESIGNED: Modern detail view, fixed favorite lag, SF Symbols
//  Location: HocaLingo/Features/AIStory/Views/StoryDetailView.swift
//

import SwiftUI

/// Story Detail View - Interactive story with word meanings
struct StoryDetailView: View {
    
    let story: GeneratedStory
    @ObservedObject var viewModel: AIStoryViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var selectedWord: WordWithMeaning? = nil
    @State private var showDeleteAlert = false
    @State private var isFavoriteLocal: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Story Content (Interactive)
                    storyContent
                    
                    // Your Words Section
                    yourWordsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.themeBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.themeSecondary)
                            .font(.system(size: 20))
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 14) {
                        // Favorite button - ✅ FIXED: Uses local state for instant feedback
                        Button {
                            // Instant local feedback
                            isFavoriteLocal.toggle()
                            // Persist to storage
                            viewModel.handle(.toggleFavorite(story.id))
                        } label: {
                            Image(systemName: isFavoriteLocal ? "heart.fill" : "heart")
                                .foregroundColor(isFavoriteLocal ? .red : .themeSecondary)
                                .font(.system(size: 18))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavoriteLocal)
                        }
                        
                        // Delete button
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.themeSecondary)
                                .font(.system(size: 16))
                        }
                    }
                }
            }
            .alert("ai_story_delete_title", isPresented: $showDeleteAlert) {
                Button("ai_story_delete_confirm", role: .destructive) {
                    viewModel.handle(.deleteStory(story.id))
                    dismiss()
                }
                Button("cancel_button", role: .cancel) {}
            } message: {
                Text("ai_story_delete_message")
            }
            .sheet(item: $selectedWord) { word in
                WordMeaningSheet(word: word)
                    .presentationDetents([.height(200)])
            }
            .onAppear {
                isFavoriteLocal = story.isFavorite
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 10) {
            // Type + Length badges
            HStack(spacing: 8) {
                // Type badge
                HStack(spacing: 5) {
                    Image(systemName: story.type.iconName)
                        .font(.system(size: 11, weight: .semibold))
                    Text(story.type.displayName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(story.type.iconColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(story.type.iconColor.opacity(0.1))
                )
                
                // Length badge
                HStack(spacing: 5) {
                    Image(systemName: story.length.iconName)
                        .font(.system(size: 11, weight: .semibold))
                    Text(story.length.displayName)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
                .foregroundColor(.themeSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.themeSecondary.opacity(0.1))
                )
                
                Spacer()
            }
            
            // Title
            Text(story.title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.themePrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Date + word count
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(story.formattedDate)
                        .font(.system(size: 12))
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "textformat.abc")
                        .font(.system(size: 11))
                    Text("ai_story_words_used_\(story.usedWords.count)")
                        .font(.system(size: 12))
                }
                
                Spacer()
            }
            .foregroundColor(.themeSecondary)
        }
    }
    
    // MARK: - Story Content
    
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reading indicator
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 12))
                Text("ai_story_reading_section")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.accentPurple)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Story text with highlighted words
            InteractiveStoryText(
                content: story.content,
                words: story.usedWords,
                onWordTap: { word in
                    selectedWord = word
                }
            )
            .font(.system(size: 16, design: .serif))
            .lineSpacing(7)
            .foregroundColor(.themePrimary)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.themeCard)
                .shadow(color: .black.opacity(isDarkMode ? 0.15 : 0.04), radius: 6, y: 2)
        )
    }
    
    // MARK: - Your Words Section
    
    private var yourWordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.accentPurple)
                
                Text("ai_story_your_words")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.themePrimary)
                
                Spacer()
                
                Text("\(story.usedWords.count)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.accentPurple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.accentPurple.opacity(0.1))
                    )
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(story.usedWords) { word in
                    WordCard(word: word)
                        .onTapGesture {
                            selectedWord = word
                        }
                }
            }
        }
    }
    
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }
}

// MARK: - Interactive Story Text

struct InteractiveStoryText: View {
    let content: String
    let words: [WordWithMeaning]
    let onWordTap: (WordWithMeaning) -> Void
    
    var body: some View {
        Text(buildAttributedString())
            .environment(\.openURL, OpenURLAction { url in
                if let wordId = Int(url.absoluteString.replacingOccurrences(of: "word://", with: "")) {
                    if let word = words.first(where: { $0.id == wordId }) {
                        onWordTap(word)
                    }
                }
                return .handled
            })
    }
    
    private func buildAttributedString() -> AttributedString {
        var attributedString = AttributedString(content)
        
        for word in words {
            let ranges = word.wholeWordRanges(in: content)
            
            for range in ranges {
                if let attributedRange = Range<AttributedString.Index>(range, in: attributedString) {
                    // Purple color for deck words
                    attributedString[attributedRange].foregroundColor = Color(hex: "6366F1")
                    attributedString[attributedRange].font = .system(size: 16, weight: .bold, design: .serif)
                    attributedString[attributedRange].underlineStyle = .single
                    attributedString[attributedRange].link = URL(string: "word://\(word.id)")
                }
            }
        }
        
        return attributedString
    }
}

// MARK: - Word Card (Modernized)

struct WordCard: View {
    let word: WordWithMeaning
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(word.english)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "6366F1"))
            
            Text(word.turkish)
                .font(.system(size: 12))
                .foregroundColor(.themeSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "6366F1").opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "6366F1").opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Word Meaning Sheet

struct WordMeaningSheet: View {
    let word: WordWithMeaning
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.themeSecondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            VStack(spacing: 12) {
                Text(word.english)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Image(systemName: "arrow.down")
                    .font(.system(size: 16))
                    .foregroundColor(.themeSecondary)
                
                Text(word.turkish)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.themePrimary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.themeBackground)
    }
}

// MARK: - WordWithMeaning Identifiable for sheet binding

// Already Identifiable via id property

// MARK: - Preview

#Preview {
    StoryDetailView(
        story: GeneratedStory(
            title: "Test Story",
            content: "This is a test story with some happy words.",
            usedWordIds: [1],
            usedWords: [WordWithMeaning(id: 1, english: "happy", turkish: "mutlu")],
            topic: nil,
            type: .motivation,
            length: .short
        ),
        viewModel: AIStoryViewModel()
    )
}
