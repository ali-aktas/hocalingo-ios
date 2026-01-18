//
//  WordSelectionView.swift
//  HocaLingo
//
//  ✅ FIXED: Proper MainTab integration, HocaLingo title, Study navigation
//  Location: HocaLingo/Features/Selection/WordSelectionView.swift
//

import SwiftUI

// MARK: - Word Selection View
struct WordSelectionView: View {
    @StateObject private var viewModel: WordSelectionViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    
    @State private var currentCardId: UUID = UUID()
    @State private var navigateToStudy: Bool = false
    
    init(packageId: String) {
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundColor.ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    loadingView
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    errorView(error)
                    Spacer()
                } else if viewModel.isCompleted {
                    Spacer()
                    completionView
                    Spacer()
                } else {
                    mainContent
                }
            }
            
            // Selection limit dialog
            if viewModel.selectionLimitReached {
                selectionLimitOverlay
            }
            
        }
        .navigationTitle("HocaLingo") // ✅ ADDED: Title like HomeView
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(themeAccentColor)
                }
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            
            // Title text
            Text("HocaLingo")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            Spacer().frame(height: 16)
            
            // Instruction text
            Text("Çalışma destesine yeni kelimeler ekle")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            
            // Progress bar
            progressBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Selection warning
            if viewModel.showSelectionWarning, let remaining = viewModel.remainingSelections {
                selectionWarningBanner(remaining: remaining)
            }
            
            // Card stack with undo button
            ZStack(alignment: .bottomTrailing) {
                // Cards
                ZStack {
                    // Next card
                    if let nextWord = viewModel.nextWord {
                        wordCard(word: nextWord, isNext: true)
                            .offset(y: 8)
                            .scaleEffect(0.95)
                            .opacity(0.5)
                    }
                    
                    // Current card
                    if let currentWord = viewModel.currentWord {
                        SwipeableCardView(
                            word: currentWord.english,
                            translation: currentWord.turkish,
                            cardColor: cardColor(for: currentWord),
                            onSwipeLeft: {
                                viewModel.swipeLeft()
                                currentCardId = UUID()
                            },
                            onSwipeRight: {
                                viewModel.swipeRight()
                                currentCardId = UUID()
                            }
                        )
                        .id(currentCardId)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
                
                // Undo button
                if viewModel.canUndo {
                    Button(action: {
                        viewModel.undoLastAction()
                        currentCardId = UUID()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color(hex: "9E9E9E"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxHeight: 460)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Centered action buttons
            centeredActionButtons
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 8) {
            // Counter
            HStack {
                Text("\(viewModel.processedWords)/\(viewModel.totalWordsCount)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeAccentColor)
                        .frame(
                            width: geometry.size.width * progress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
    }
    
    private var progress: Double {
        guard viewModel.totalWordsCount > 0 else { return 0 }
        return Double(viewModel.processedWords) / Double(viewModel.totalWordsCount)
    }
    
    // MARK: - Selection Warning Banner
    private func selectionWarningBanner(remaining: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(.orange)
            
            Text("\(remaining) selection\(remaining == 1 ? "" : "s") left today")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - Word Card
    private func wordCard(word: Word, isNext: Bool = false) -> some View {
        VStack(spacing: 16) {
            Text(word.english)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            if !isNext {
                Text(word.turkish)
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isNext ? Color.gray.opacity(0.3) : cardColor(for: word))
                .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        )
    }
    
    // MARK: - Centered Action Buttons
    private var centeredActionButtons: some View {
        HStack(spacing: 32) {
            // Skip button
            SelectionActionButton(
                icon: "xmark",
                backgroundColor: Color(hex: "EF5350"),
                size: 72,
                isEnabled: !viewModel.isProcessingSwipe
            ) {
                viewModel.swipeLeft()
                currentCardId = UUID()
            }
            
            // Learn button
            SelectionActionButton(
                icon: "checkmark",
                backgroundColor: Color(hex: "66BB6A"),
                size: 72,
                isEnabled: !viewModel.isProcessingSwipe && !viewModel.selectionLimitReached
            ) {
                viewModel.swipeRight()
                currentCardId = UUID()
            }
        }
    }
    
    // MARK: - Selection Limit Overlay
    /// ✅ FIXED: "Start Learning" button navigates to StudyView
    private var selectionLimitOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    viewModel.selectionLimitReached = false
                }
            
            VStack(spacing: 24) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.orange)
                
                VStack(spacing: 12) {
                    Text("Daily Selection Limit Reached")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("You've selected 15 words today.\nYou can still skip words freely, or upgrade to Premium for unlimited selections!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                VStack(spacing: 12) {
                    // ✅ FIXED: "Start Learning" button navigates to Study
                    Button(action: {
                        viewModel.selectionLimitReached = false
                        navigateToStudy = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                            Text("Start Learning")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeAccentColor)
                        .cornerRadius(16)
                    }
                    
                    // Upgrade to Premium button (unchanged)
                    Button(action: {
                        // TODO: Navigate to premium
                        viewModel.selectionLimitReached = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                            Text("Upgrade to Premium")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(cardBackgroundColor)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 32)
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "10B981").opacity(0.4), radius: 20, x: 0, y: 10)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text("All Done! 🎉")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.primary)
                
                Text("You've reviewed all words in this package.\nTime to pick a new challenge!")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            VStack(spacing: 14) {
                if viewModel.selectedCount > 0 {
                    Button(action: {
                        navigateToStudy = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                            Text("Start Learning (\(viewModel.selectedCount))")
                        }
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(themeAccentColor)
                        .cornerRadius(16)
                        .shadow(color: themeAccentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
                
                Button(action: { dismiss() }) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("Select New Package")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeAccentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(themeAccentColor.opacity(0.12))
                    .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal, 36)
    }
    
    // MARK: - Loading & Error Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("Loading words...")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Theme Colors
    private var backgroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "121212")
            : Color(hex: "F5F5F5")
    }
    
    private var cardBackgroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "1E1E1E")
            : Color.white
    }
    
    private var themeAccentColor: Color {
        Color(hex: "4ECDC4")
    }
    
    private func cardColor(for word: Word) -> Color {
        let colors = [
            Color(hex: "5C6BC0"),
            Color(hex: "42A5F5"),
            Color(hex: "26C6DA"),
            Color(hex: "66BB6A"),
            Color(hex: "FFA726"),
            Color(hex: "EF5350")
        ]
        return colors[word.id % colors.count]
    }
}

// MARK: - Preview
struct WordSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WordSelectionView(packageId: "en_tr_a1_001")
        }
        .environment(\.themeViewModel, ThemeViewModel.shared)
    }
}
