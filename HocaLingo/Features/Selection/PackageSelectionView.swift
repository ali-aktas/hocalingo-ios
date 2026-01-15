import SwiftUI

// MARK: - Package Selection View
/// Package selection screen with level grid (A1-C2)
/// Location: HocaLingo/Features/Selection/PackageSelectionView.swift
struct PackageSelectionView: View {
    @StateObject private var viewModel = PackageSelectionViewModel()
    @State private var selectedPackageForNavigation: String? = nil
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Package Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.packages) { package in
                            PackageCard(
                                package: package,
                                isSelected: viewModel.selectedPackageId == package.id
                            ) {
                                viewModel.selectPackage(package.id)
                                selectedPackageForNavigation = package.id
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 20)
            }
            .sheet(item: Binding(
                get: { selectedPackageForNavigation.map { PackageNavigationItem(id: $0) } },
                set: { selectedPackageForNavigation = $0?.id }
            )) { item in
                WordSelectionView(packageId: item.id)
            }
            .navigationTitle("package_selection_title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("package_selection_subtitle")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Package Card Component
struct PackageCard: View {
    let package: PackageModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Level Badge
                HStack {
                    Text(package.level)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Title & Description
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(package.description)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Word count
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 12))
                        Text(String(format: NSLocalizedString("package_words_count", comment: ""), package.wordCount))
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(height: 180)
            .background(package.color)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Navigation Item
struct PackageNavigationItem: Identifiable {
    let id: String
}

// MARK: - Preview
#Preview {
    PackageSelectionView()
}
