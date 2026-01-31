//
//  StoryDetailView.swift
//  HocaLingo
//
//  Features/AIStory/Views/StoryDetailView.swift
//  Story detail with interactive word highlighting
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Story Content (Interactive)
                    storyContent
                    
                    // Your Words Section
                    yourWordsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Favorite button
                        Button {
                            viewModel.handle(.toggleFavorite(story.id))
                        } label: {
                            Image(systemName: story.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(story.isFavorite ? .red : .themeSecondary)
                                .font(.title3)
                        }
                        
                        // Delete button
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.themeSecondary)
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(item: $selectedWord) { word in
                WordMeaningSheet(word: word)
                    .presentationDetents([.height(200)])
            }
            .alert("Hikayeyi Sil", isPresented: $showDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    viewModel.handle(.deleteStory(story.id))
                    dismiss()
                }
            } message: {
                Text("Bu hikayeyi silmek istediğinizden emin misiniz?")
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Type icon
            Text(story.type.icon)
                .font(.system(size: 48))
            
            // Title
            Text(story.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.themePrimary)
                .multilineTextAlignment(.center)
            
            // Metadata
            HStack(spacing: 16) {
                Label(story.length.displayName, systemImage: story.length.icon)
                    .font(.system(size: 13))
                    .foregroundColor(.themeSecondary)
                
                Text("•")
                    .foregroundColor(.themeSecondary)
                
                Text(story.formattedDate)
                    .font(.system(size: 13))
                    .foregroundColor(.themeSecondary)
            }
        }
    }
    
    private var storyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Hint
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.accentPurple)
                Text("tap_word_hint")
                    .font(.system(size: 12))
                    .foregroundColor(.themeSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentPurple.opacity(0.1))
            )
            
            // Story text with highlighted words
            InteractiveStoryText(
                content: story.content,
                words: story.usedWords,
                onWordTap: { word in
                    selectedWord = word
                }
            )
            .font(.system(size: 17, design: .serif))
            .lineSpacing(6)
            .foregroundColor(.themePrimary)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.themeCard)
            )
        }
    }
    
    private var yourWordsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("your_words")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.themePrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(story.usedWords) { word in
                    WordCard(word: word)
                }
            }
        }
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
                // Handle word tap
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
        
        // Highlight each word
        for word in words {
            let ranges = word.ranges(in: content)
            
            for range in ranges {
                if let attributedRange = Range<AttributedString.Index>(range, in: attributedString) {
                    // Purple color
                    attributedString[attributedRange].foregroundColor = Color(hex: "6366F1")
                    
                    // Bold
                    attributedString[attributedRange].font = .system(size: 17, weight: .bold, design: .serif)
                    
                    // Underline
                    attributedString[attributedRange].underlineStyle = .single
                    
                    // Link (for tap detection)
                    attributedString[attributedRange].link = URL(string: "word://\(word.id)")
                }
            }
        }
        
        return attributedString
    }
}

// MARK: - Word Card

struct WordCard: View {
    let word: WordWithMeaning
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.english)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "6366F1"))
            
            Text(word.turkish)
                .font(.system(size: 14))
                .foregroundColor(.themeSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.themeCard)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "6366F1").opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Word Meaning Sheet

struct WordMeaningSheet: View {
    let word: WordWithMeaning
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 6)
                .padding(.top, 12)
            
            // Content
            VStack(spacing: 12) {
                Text(word.english)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "6366F1"))
                
                Text(word.turkish)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.themePrimary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeBackground)
    }
}
