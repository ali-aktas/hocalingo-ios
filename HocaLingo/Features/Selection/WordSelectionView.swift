import SwiftUI

// MARK: - Word Selection View
/// Word selection screen with scrollable list and checkboxes
/// Location: HocaLingo/Features/Selection/WordSelectionView.swift
struct WordSelectionView: View {
    @StateObject private var viewModel: WordSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(packageId: String) {
        _viewModel = StateObject(wrappedValue: WordSelectionViewModel(packageId: packageId))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading words...")
                        .font(.system(size: 16))
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else {
                    contentView
                }
            }
            .navigationTitle("Select Words")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.finishSelection()
                        dismiss()
                    }
                    .disabled(viewModel.selectedCount == 0)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {
            // Selection Counter
            selectionCounter
            
            Divider()
            
            // Word List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.words) { word in
                        WordRowView(
                            word: word,
                            isSelected: viewModel.isWordSelected(word.id)
                        ) {
                            viewModel.toggleWordSelection(word.id)
                        }
                        
                        if word.id != viewModel.words.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Selection Counter
    private var selectionCounter: some View {
        HStack {
            Text("\(viewModel.selectedCount) words selected")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            if viewModel.selectedCount > 0 {
                Button(action: {
                    viewModel.clearSelection()
                }) {
                    Text("Clear")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Error View
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text(error)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Try Again") {
                viewModel.loadWords()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Word Row View
struct WordRowView: View {
    let word: Word
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                // Word Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.english)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(word.turkish)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    if !word.example.en.isEmpty {
                        Text(word.example.en)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .italic()
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    WordSelectionView(packageId: "a1_en_tr_test_v1")
}
