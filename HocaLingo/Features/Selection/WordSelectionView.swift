//
//  WordSelectionView.swift
//  HocaLingo
//
//  Word selection screen with swipe cards and free user limits
//  Location: HocaLingo/Features/Selection/WordSelectionView.swift
//

import SwiftUI

// MARK: - Word Selection View
struct WordSelectionView: View {
    let packageId: String
    @Binding var selectedTab: Int
    
    @StateObject private var viewModel: WordSelectionViewModel
    @State private var showPremiumSheet = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    @AppStorage("app_language") private var appLanguageCode: String = "en"
    
    @State private var currentCardId: UUID = UUID()
    
    init(packageId: String, selectedTab: Binding<Int>) {
        self.packageId = packageId
        self._selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }
    
    var body: some View {
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

            Circle()
                .fill(Color.accentPurple.opacity(isDarkMode ? 0.15 : 0.08))
                .frame(width: 350, height: 350)
                .blur(radius: 60)
                .offset(x: 120, y: -250)
            
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
            
            if viewModel.selectionLimitReached {
                selectionLimitOverlay
            }
        }
        .navigationTitle("HocaLingo")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showPremiumSheet) {
                    PremiumPaywallView()
                }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .font(.system(size: 17))
                    }
                    .foregroundColor(themeAccentColor)
                }
            }
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16)
            
            Text("word_selection_instruction")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            progressBar
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            if viewModel.showSelectionWarning, let remaining = viewModel.remainingSelections {
                selectionWarningBanner(remaining: remaining)
            }
            
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    if let nextWord = viewModel.nextWord {
                        wordCard(word: nextWord, isNext: true)
                            .offset(y: 8)
                            .scaleEffect(0.95)
                            .opacity(0.5)
                    }
                    
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
            
            centeredActionButtons
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.processedWords)/\(viewModel.totalWordsCount)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
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
            
            Text("\(remaining) ") + Text("word_selection_remaining")
                .font(.system(size: 14, weight: .medium, design: .rounded))
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
                .font(.system(size: 28, weight: .bold, design: .rounded))
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
        .padding(.horizontal, 32)
    }
    
    // MARK: - Centered Action Buttons
    private var centeredActionButtons: some View {
        HStack(spacing: 24) {
            // Skip Button (Red X)
            Button(action: {
                viewModel.swipeLeft()
                currentCardId = UUID()
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "EF5350"),
                                        Color(hex: "E53935")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 85, height: 85)
                            .shadow(color: Color(hex: "EF5350").opacity(0.35), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text("word_selection_skip")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.themePrimary)
                }
            }
            .disabled(viewModel.isProcessingSwipe)
            .opacity(viewModel.isProcessingSwipe ? 0.5 : 1.0)
            
            // Learn Button (Green ✓)
            Button(action: {
                viewModel.swipeRight()
                currentCardId = UUID()
            }) {
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "66BB6A"),
                                        Color(hex: "43A047")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 85, height: 85)
                            .shadow(color: Color(hex: "66BB6A").opacity(0.35), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("word_selection_learn")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.themePrimary)
                }
            }
            .disabled(viewModel.isProcessingSwipe || viewModel.selectionLimitReached)
            .opacity((viewModel.isProcessingSwipe || viewModel.selectionLimitReached) ? 0.5 : 1.0)
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
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                Text("word_selection_complete_title")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("word_selection_complete_message")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            VStack(spacing: 14) {
                if viewModel.selectedCount > 0 {
                    Button(action: {
                        selectedTab = 1
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "book.fill")
                            Text("word_selection_start_learning") + Text(" (\(viewModel.selectedCount))")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
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
                        Text("word_selection_new_package")
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
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
    
    // MARK: - Selection Limit Overlay
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
                    Text("word_selection_limit_title")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("word_selection_limit_message")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                
                VStack(spacing: 12) {
                    if viewModel.selectedCount > 0 {
                        Button(action: {
                            viewModel.selectionLimitReached = false
                            selectedTab = 1
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "book.fill")
                                Text("word_selection_start_learning") + Text(" (\(viewModel.selectedCount))")
                            }
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeAccentColor)
                            .cornerRadius(14)
                        }
                    }
                    
                    Button(action: {
                        viewModel.selectionLimitReached = false
                        showPremiumSheet = true
                    }) {
                        Text("Premium'a Geç")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(themeAccentColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(themeAccentColor.opacity(0.12))
                            .cornerRadius(14)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Loading & Error Views
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.5)
            Text("loading")
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
    private var isDarkMode: Bool {
        themeViewModel.isDarkMode(in: colorScheme)
    }

    private var backgroundColor: Color {
        themeViewModel.isDarkMode(in: colorScheme)
            ? Color(hex: "1A1625")
            : Color(hex: "FBF2FF")
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
            WordSelectionView(packageId: "en_tr_a1_001", selectedTab: .constant(0))
        }
        .environment(\.themeViewModel, ThemeViewModel.shared)
    }
}
