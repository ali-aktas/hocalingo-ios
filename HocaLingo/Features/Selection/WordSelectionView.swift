//
//  WordSelectionView.swift
//  HocaLingo
//
//  FINAL VERSION - All errors fixed
//  Location: HocaLingo/Features/Selection/WordSelectionView.swift
//

import SwiftUI

// MARK: - Word Selection View
struct WordSelectionView: View {
    @StateObject private var viewModel: WordSelectionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var navigateToStudy: Bool = false
    @State private var currentCardId: UUID = UUID()
    
    init(packageId: String) {
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
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
                
                NavigationLink(
                    destination: StudyView(),
                    isActive: $navigateToStudy
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
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
            })
        }
        .navigationViewStyle(.stack)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            ZStack {
                if viewModel.isProcessingSwipe {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                        .zIndex(10)
                }
                
                cardStack
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .bottom) {
            actionButtons
        }
    }
    
    private var cardStack: some View {
        ZStack {
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
            
            if let currentWord = viewModel.currentWord {
                SwipeableCardView(
                    word: currentWord.english,
                    translation: currentWord.turkish,
                    cardColor: viewModel.getCardColor(for: currentWord),
                    onSwipeLeft: { viewModel.swipeLeft() },
                    onSwipeRight: { viewModel.swipeRight() }
                )
                .id(currentCardId)
                .zIndex(1)
            } else {
                Text("Kelime yükleniyor...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Text("\(viewModel.selectedCount) seçildi")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    viewModel.undo()
                    currentCardId = UUID()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Geri Al")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(viewModel.canUndo ? Color(hex: "FF9500") : .gray)
                }
                .disabled(!viewModel.canUndo)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.swipeLeft()
                    currentCardId = UUID()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color(hex: "FF6B6B"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    navigateToStudy = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Çalış (\(viewModel.selectedCount))")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(32)
                    .shadow(color: Color(hex: "4ECDC4").opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .disabled(viewModel.selectedCount == 0)
                .opacity(viewModel.selectedCount == 0 ? 0.5 : 1.0)
                
                Button(action: {
                    viewModel.swipeRight()
                    currentCardId = UUID()
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(Color(hex: "66BB6A"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Kelimeler yükleniyor...")
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
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "66BB6A"))
            
            Text("Tamamlandı! 🎉")
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

// MARK: - Preview
struct WordSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        WordSelectionView(packageId: "en_tr_a1_001")
    }
}
