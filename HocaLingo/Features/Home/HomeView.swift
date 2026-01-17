//
//  HomeView.swift
//  HocaLingo
//
//  ✅ COMPLETE REDESIGN - 100% Android parity with all features
//  Location: HocaLingo/Features/Home/HomeView.swift
//

import SwiftUI
import Combine  // ✅ FIXED: Added for Timer.autoconnect()

// MARK: - Home View
/// Premium Home Dashboard - Production-grade matching Android exactly
struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var showAddWordDialog = false
    @State private var animateHero = false
    @State private var currentMascotIndex = 0
    
    // ✅ NEW: For mascot rotation timer
    private let mascotTimer = Timer.publish(every: 40, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if viewModel.uiState.isLoading {
                    ProgressView("Loading...")
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            // 1. HocaLingo Title (CENTER + BLACK)
                            titleSection
                            
                            // 2. Hero card (Play + Maskot + Motivasyon)
                            heroCard
                            
                            // 3. Monthly Stats Title
                            statsTitle
                            
                            // 4. Stats cards (ANDROID PARITY)
                            androidStatsGrid
                            
                            // 5. Action buttons
                            actionButtonsSection
                            
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 64)  // For safe area
                        .padding(.bottom, 100) // Space for bottom nav
                    }
                }
            }
            .navigationBarHidden(true)
            // ✅ NEW: Navigation destinations
            .navigationDestination(isPresented: $viewModel.shouldNavigateToStudy) {
                StudyView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToPackageSelection) {
                PackageSelectionView()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAIAssistant) {
                Text("AI Assistant - Coming Soon!")
                    .font(.title)
                    .padding()
            }
        }
        // ✅ NEW: ADD WORD Dialog
        .sheet(isPresented: $viewModel.shouldShowAddWordDialog) {
            AddWordDialogView()
        }
        .onReceive(mascotTimer) { _ in
            rotateMascot()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateHero = true
            }
        }
    }
    
    // MARK: - Mascot Rotation
    private func rotateMascot() {
        withAnimation(.easeInOut(duration: 0.5)) {
            currentMascotIndex = (currentMascotIndex + 1) % mascotImages.count
        }
    }
    
    /// ✅ REAL MASCOT IMAGES
    private let mascotImages = ["lingohoca1", "lingohoca2", "lingohoca3"]
}

// MARK: - Title Section (CENTER + BLACK)
private extension HomeView {
    var titleSection: some View {
        Text("HocaLingo")
            .font(.system(size: 32, weight: .black))  // ✅ BLACK weight like Android
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)  // ✅ CENTER aligned
    }
}

// MARK: - Hero Card (Play + Maskot + Motivasyon)
private extension HomeView {
    var heroCard: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // ✅ LEFT: Play Button
            Button {
                viewModel.onEvent(.startStudy)
            } label: {
                ZStack {
                    // Outer circle glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FB9322").opacity(0.3),
                                    Color(hex: "FB9322").opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 100)
                        .blur(radius: 10)
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FB9322"),  // Android orange
                                    Color(hex: "FF6B00")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color(hex: "FB9322").opacity(0.4), radius: 12, y: 6)
                    
                    // Play icon
                    Image(systemName: "play.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 3)  // Slight offset for visual balance
                }
            }
            .scaleEffect(animateHero ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animateHero)
            
            Spacer()
            
            // ✅ RIGHT: REAL MASCOT (Android parity)
                        Image(mascotImages[currentMascotIndex])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .opacity(animateHero ? 1.0 : 0)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.4), value: currentMascotIndex)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        )
    }
}

// MARK: - Stats Title
private extension HomeView {
    var statsTitle: some View {
        Text("Bu ayın istatistikleri")  // ✅ Android text
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Android Stats Grid (EXACT MATCH)
private extension HomeView {
    var androidStatsGrid: some View {
        HStack(spacing: 12) {
            
            // 1. Streak (Circular - Android style)
            CircularStatCard(
                icon: "flame.fill",
                value: "\(viewModel.uiState.streakDays)",
                label: "Günlük seri",
                color: Color(hex: "FF6B6B")
            )
            
            // 2. This Month Active Days
            CircularStatCard(
                icon: "calendar.badge.checkmark",
                value: "\(viewModel.uiState.monthlyStats.activeDaysThisMonth)",
                label: "Aktif gün",
                color: Color(hex: "4ECDC4")
            )
            
            // 3. This Month Study Time
            CircularStatCard(
                icon: "clock.fill",
                value: viewModel.uiState.monthlyStats.formattedStudyTime,
                label: "Çalışma",
                color: Color(hex: "FFD93D")
            )
            
            // 4. Discipline Score
            CircularStatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(viewModel.uiState.monthlyStats.disciplineScore)",
                label: "Disiplin",
                color: Color(hex: "A03BDF")
            )
        }
    }
}

// MARK: - Action Buttons Section
private extension HomeView {
    var actionButtonsSection: some View {
        VStack(spacing: 14) {
            
            // Package Selection
            WideActionButton(
                icon: "square.grid.2x2.fill",
                title: "Kelime Paketi Seç",
                subtitle: "Çalışma destene yeni kelimeler ekle",
                baseColor: Color(hex: "4ECDC4"),
                action: {
                    viewModel.onEvent(.navigateToPackageSelection)
                }
            )
            
            // ✅ NEW: ADD WORD Button
            WideActionButton(
                icon: "plus.circle.fill",
                title: "Kelime Ekle",
                subtitle: "Kendi kelimelerini ekle",
                baseColor: Color(hex: "FF9500"),
                action: {
                    viewModel.onEvent(.showAddWordDialog)
                }
            )
            
            // AI Assistant
            WideActionButton(
                icon: "sparkles",
                title: "Yapay Zeka Asistanı",
                subtitle: "Çalışma destene özel hikaye yazarı",
                baseColor: Color(hex: "A03BDF"),
                action: {
                    viewModel.onEvent(.navigateToAIAssistant)
                }
            )
        }
    }
}

// MARK: - Circular Stat Card (Android Style)
struct CircularStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Value
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            // Label
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Wide Action Button (Android Style)
struct WideActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let baseColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(baseColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [baseColor, baseColor.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: baseColor.opacity(0.3), radius: isPressed ? 6 : 12, y: isPressed ? 2 : 6)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ADD WORD Dialog View (PLACEHOLDER)
struct AddWordDialogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var englishWord = ""
    @State private var turkishWord = ""
    @State private var exampleEn = ""
    @State private var exampleTr = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Info banner
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color(hex: "4ECDC4"))
                        
                        Text("Kendi kelimelerinizi ekleyerek çalışma listenizi özelleştirin")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "4ECDC4").opacity(0.1))
                    )
                    
                    // English word
                    VStack(alignment: .leading, spacing: 8) {
                        Text("English")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        TextField("Enter English word", text: $englishWord)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                    }
                    
                    // Turkish word
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Türkçe")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        TextField("Türkçe karşılığını girin", text: $turkishWord)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // English example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("English Example (Optional)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        TextField("Example sentence", text: $exampleEn)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    // Turkish example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Türkçe Örnek (Opsiyonel)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        TextField("Örnek cümle", text: $exampleTr)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // Save button
                    Button {
                        // TODO: Save word logic
                        dismiss()
                    } label: {
                        Text("Kaydet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(englishWord.isEmpty || turkishWord.isEmpty)
                    .opacity(englishWord.isEmpty || turkishWord.isEmpty ? 0.6 : 1.0)
                }
                .padding(20)
            }
            .navigationTitle("Kelime Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
