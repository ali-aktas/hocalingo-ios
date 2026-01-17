import SwiftUI

// MARK: - Word Selection View (FIXED NAVIGATION)
/// Production-grade word selection screen with proper navigation
/// FIXES:
/// - Added NavigationStack (works inside .sheet)
/// - Study button navigation fixed
/// - Proper dismiss handling
/// Location: HocaLingo/Features/WordSelection/WordSelectionView.swift
struct WordSelectionView: View {
    // MARK: - Properties
    @StateObject private var viewModel: WordSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    @State private var navigateToStudy: Bool = false
    @State private var currentCardId: UUID = UUID() // Force card refresh
    
    // MARK: - Card Reference (for button triggers)
    @State private var triggerSwipeLeft: Bool = false
    @State private var triggerSwipeRight: Bool = false
    
    // MARK: - Initialization
    init(packageId: String) {
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }
    
    // MARK: - Body
    var body: some View {
        // ✅ FIXED: NavigationStack wrapper for .sheet presentation
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.isCompleted {
                    completionView
                } else {
                    mainContent
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Geri")
                        }
                        .foregroundColor(Color(hex: "FF6B6B"))
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Hocalingo")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            // ✅ FIXED: Navigation destination inside NavigationStack
            .navigationDestination(isPresented: $navigateToStudy) {
                StudyView()
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Card stack area (full height)
            ZStack {
                // Processing indicator overlay
                if viewModel.isProcessingSwipe {
                    ProcessingIndicator(isProcessing: true)
                        .zIndex(10)
                }
                
                // Card stack
                cardStack
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .bottom) {
            actionButtons
        }
    }
    
    // MARK: - Card Stack
    private var cardStack: some View {
        ZStack {
            // Next card (background preview)
            if let nextWord = viewModel.nextWord {
                SwipeableCardView(
                    word: nextWord.english,
                    translation: nextWord.turkish,
                    cardColor: viewModel.getCardColor(for: nextWord),
                    onSwipeLeft: {},
                    onSwipeRight: {}
                )
                .scaleEffect(0.95)
                .opacity(0.6)
                .allowsHitTesting(false)
                .zIndex(0)
            }
            
            // Current card (foreground interactive)
            if let currentWord = viewModel.currentWord {
                SwipeableCardViewWrapper(
                    word: currentWord.english,
                    translation: currentWord.turkish,
                    cardColor: viewModel.getCardColor(for: currentWord),
                    triggerSwipeLeft: $triggerSwipeLeft,
                    triggerSwipeRight: $triggerSwipeRight,
                    onSwipeLeft: {
                        viewModel.hideWord(currentWord.id)
                        currentCardId = UUID() // Force refresh
                    },
                    onSwipeRight: {
                        viewModel.selectWord(currentWord.id)
                        currentCardId = UUID() // Force refresh
                    }
                )
                .id(currentCardId) // Force new card instance
                .zIndex(1)
            } else {
                // No words left
                noWordsView
            }
        }
    }
    
    // MARK: - Action Buttons (Clean Layout)
    private var actionButtons: some View {
        HStack(spacing: 0) {
            Spacer()
            
            // ✅ FIXED: Study button navigation
            SelectionSmallButton(
                icon: "play.fill",
                backgroundColor: Color(hex: "66BB6A"),
                isEnabled: viewModel.selectedCount > 0 && !viewModel.isProcessingSwipe
            ) {
                // Finish selection and navigate
                viewModel.finishSelection()
                
                // Small delay to ensure data is saved
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToStudy = true
                }
            }
            
            Spacer()
            
            // Skip button (large) - RED
            SelectionActionButton(
                icon: "xmark",
                backgroundColor: Color(hex: "EF5350"),
                size: 80,
                isEnabled: !viewModel.isProcessingSwipe && viewModel.currentWord != nil
            ) {
                triggerSwipeLeft = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    triggerSwipeLeft = false
                }
            }
            
            Spacer()
            
            // Learn button (large) - GREEN
            SelectionActionButton(
                icon: "checkmark",
                backgroundColor: Color(hex: "66BB6A"),
                size: 80,
                isEnabled: !viewModel.isProcessingSwipe && viewModel.currentWord != nil
            ) {
                triggerSwipeRight = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    triggerSwipeRight = false
                }
            }
            
            Spacer()
            
            // Undo button
            SelectionSmallButton(
                icon: "arrow.uturn.backward",
                backgroundColor: Color(hex: "2196F3"),
                isEnabled: viewModel.canUndo
            ) {
                viewModel.undo()
                currentCardId = UUID() // Force refresh
            }
            
            Spacer()
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            Color(.systemBackground)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        CompletionView(
            selectedCount: viewModel.selectedCount,
            hiddenCount: viewModel.hiddenCount,
            onContinue: {
                viewModel.finishSelection()
                
                // Small delay to ensure data is saved
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigateToStudy = true
                }
            },
            onGoHome: {
                dismiss()
            }
        )
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Kelimeler yükleniyor...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "FF6B6B"))
            
            Text("Hata")
                .font(.system(size: 24, weight: .bold))
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.loadWords()
            }) {
                Text("Tekrar Dene")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "FF6B6B"))
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - No Words View
    private var noWordsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "66BB6A"))
            
            Text("Tüm Kelimeler İşlendi! 🎉")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Bu paketteki tüm kelimeleri gözden geçirdin.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Ana Sayfaya Dön")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(Color(hex: "66BB6A"))
                .cornerRadius(16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
    }
}

// MARK: - Swipeable Card Wrapper
/// Wrapper to handle button triggers and communicate with card
struct SwipeableCardViewWrapper: View {
    let word: String
    let translation: String
    let cardColor: Color
    @Binding var triggerSwipeLeft: Bool
    @Binding var triggerSwipeRight: Bool
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    
    var body: some View {
        SwipeableCardView(
            word: word,
            translation: translation,
            cardColor: cardColor,
            onSwipeLeft: onSwipeLeft,
            onSwipeRight: onSwipeRight
        )
        .onChange(of: triggerSwipeLeft) { _, newValue in
            if newValue {
                // Trigger left swipe programmatically
                performSwipe(direction: .left)
            }
        }
        .onChange(of: triggerSwipeRight) { _, newValue in
            if newValue {
                // Trigger right swipe programmatically
                performSwipe(direction: .right)
            }
        }
    }
    
    private func performSwipe(direction: SwipeDirection) {
        // Swipe is handled by callbacks
        if direction == .left {
            onSwipeLeft()
        } else {
            onSwipeRight()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        WordSelectionView(packageId: "basic")
    }
}
