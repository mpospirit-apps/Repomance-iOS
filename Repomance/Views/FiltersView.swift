//
//  FiltersView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

struct FiltersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var repoCache = RepoCache.shared
    private let apiService = CustomAPIService.shared
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var isGeneratingBatch = false
    @State private var availableCategories: [String] = []
    @State private var filteredRepoCount: Int? = nil
    @Binding var newBatchGenerated: Bool
    let dailyBatchCount: Int

    // Check if user has reached batch limit
    private var hasReachedBatchLimit: Bool {
        let limit = 10
        return dailyBatchCount >= limit
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Filters Section
                        VStack(alignment: .leading, spacing: 12) {
                            // Category Filter
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Categories")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.textPrimary)

                                // Category checkboxes in flow layout
                                FlowLayout(spacing: 8) {
                                    ForEach(availableCategories, id: \.self) { category in
                                        Button(action: {
                                            if hapticFeedbackEnabled {
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.impactOccurred()
                                            }

                                            if repoCache.filterCategories.contains(category) {
                                                repoCache.filterCategories.removeAll { $0 == category }
                                            } else {
                                                repoCache.filterCategories.append(category)
                                            }
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(repoCache.filterCategories.contains(category) ? .checkboxChecked : .checkboxUnchecked)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 16, height: 16)
                                                Text(category)
                                                    .font(.subheadline)
                                                    .fontWeight(.bold)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                        }
                                        .buttonStyle(BrutalistButtonStyle(
                                            backgroundColor: repoCache.filterCategories.contains(category) ? (Color.appAccent) : Color.appBackgroundLight,
                                            foregroundColor: repoCache.filterCategories.contains(category) ? .white : Color.textPrimary,
                                            shadow: .smallBlack
                                        ))
                                    }
                                }
                            }

                            // Star Count Range
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Star Count Range")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.textPrimary)

                                HStack(spacing: 12) {
                                    TextField("Min", text: $repoCache.filterMinStars)
                                        .keyboardType(.numberPad)
                                        .onChange(of: repoCache.filterMinStars) { _, newValue in
                                            // Filter out non-numeric characters
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered != newValue {
                                                repoCache.filterMinStars = filtered
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.appBackgroundLight)
                                        .foregroundColor(Color.textPrimary)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                                        )
                                        .brutalistShadow(BrutalistStyle.Shadow.smallBlack)

                                    TextField("Max", text: $repoCache.filterMaxStars)
                                        .keyboardType(.numberPad)
                                        .onChange(of: repoCache.filterMaxStars) { _, newValue in
                                            // Filter out non-numeric characters
                                            let filtered = newValue.filter { $0.isNumber }
                                            if filtered != newValue {
                                                repoCache.filterMaxStars = filtered
                                            }
                                        }
                                        .padding(12)
                                        .background(Color.appBackgroundLight)
                                        .foregroundColor(Color.textPrimary)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                                        )
                                        .brutalistShadow(BrutalistStyle.Shadow.smallBlack)
                                }
                            }
                            .padding(.top, 8)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 220) // Add space for expected repo count card and buttons at bottom
                }

                // Buttons - Fixed at bottom
                VStack(spacing: 12) {
                    // Expected Repo Count Card
                    if let count = filteredRepoCount {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(.document)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(
                                        count < 10 ? .yellow : (Color.appAccent)
                                    )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Expected Batch Size")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.textSecondary)

                                    Text("\(count) repositories")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(count < 10 ? .yellow : Color.textPrimary)
                                }

                                Spacer()
                            }

                            if count < 10 {
                                Divider()
                                    .background(Color.textSecondary.opacity(0.3))

                                HStack(alignment: .top, spacing: 8) {
                                    Image(.warning)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.yellow)
                                    Text("Your current filters will return fewer than 10 repositories. Consider adjusting your filters.")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.appBackgroundLight)
                        .overlay(
                            Rectangle()
                                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                        )
                        .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                    }

                    // Clear Filters Button
                    Button(action: {
                        if hapticFeedbackEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        clearFilters()
                    }) {
                        HStack {
                            Image(.close)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text("CLEAR FILTERS")
                                .fontWeight(.black)
                                .textCase(.uppercase)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                    .buttonStyle(BrutalistButtonStyle(
                        backgroundColor: Color.appBackgroundLight,
                        foregroundColor: Color.textPrimary
                    ))

                    // Generate New Batch Button
                    Button(action: {
                        if hapticFeedbackEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        generateNewBatch()
                    }) {
                        HStack {
                            if isGeneratingBatch {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(hasReachedBatchLimit ? .lock : .refresh)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text(hasReachedBatchLimit ? "DAILY LIMIT REACHED" : "GENERATE NEW BATCH")
                                .fontWeight(.black)
                                .textCase(.uppercase)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .opacity(isGeneratingBatch || hasReachedBatchLimit ? 0.6 : 1.0)
                    }
                    .buttonStyle(BrutalistButtonStyle(
                        backgroundColor: hasReachedBatchLimit ? Color.gray : Color.appAccent
                    ))
                    .disabled(isGeneratingBatch || hasReachedBatchLimit)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
                .background(Color.appBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("FILTERS")
                            .font(.system(.headline))
                            .fontWeight(.black)
                            .textCase(.uppercase)
                            .foregroundColor(Color.appAccent)
                    }
                }
            }
            .toolbarBackground(Color.appBackgroundLight, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear {
            if hapticFeedbackEnabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
            loadCategories()
            updateRepoCount()
        }
        .onChange(of: repoCache.filterCategories.count) {
            updateRepoCount()
        }
        .onChange(of: repoCache.filterMinStars) {
            updateRepoCount()
        }
        .onChange(of: repoCache.filterMaxStars) {
            updateRepoCount()
        }
    }

    private func loadCategories() {
        apiService.fetchCategories { categories in
            self.availableCategories = categories
        }
    }

    private func clearFilters() {
        repoCache.filterCategories.removeAll()
        repoCache.filterMinStars = ""
        repoCache.filterMaxStars = ""
    }

    private func updateRepoCount() {
        guard let username = authManager.username else { return }

        repoCache.fetchBatchPreview(username: username) { count in
            self.filteredRepoCount = count
        }
    }

    private func generateNewBatch() {
        guard let username = authManager.username else { return }

        // Check if user has reached batch limit
        if hasReachedBatchLimit {
            return
        }

        isGeneratingBatch = true

        repoCache.fetchNewBatch(username: username, userId: authManager.userId) { success in
            isGeneratingBatch = false
                            if success {
                                // Mark that a new batch was generated
                                self.newBatchGenerated = true

                                dismiss() // Always dismiss the view on successful batch generation

                                // The SwipeView will handle showing the "no repos" state if no repos are present
                            }        }
    }
}
