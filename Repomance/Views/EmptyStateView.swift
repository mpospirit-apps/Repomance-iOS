//
//  EmptyStateView.swift
//  Repomance
//
//  Created on 23.12.2025.
//

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @StateObject private var repoCache = RepoCache.shared
    let noReposFound: Bool
    let isGeneratingBatch: Bool
    let dailyBatchCount: Int
    let generateNewBatch: () -> Void

    @State private var filteredRepoCount: Int? = nil

    private var limitReachedMessage: String {
        if noReposFound {
            return "Adjust your filters and try again"
        } else {
            return "Generate a batch to discover new repositories"
        }
    }

    private var hasActiveFilters: Bool {
        !repoCache.filterCategories.isEmpty ||
        !repoCache.filterMinStars.isEmpty ||
        !repoCache.filterMaxStars.isEmpty ||
        !repoCache.filterLanguages.isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            Image(noReposFound ? .search : .inbox)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(
                    noReposFound ? .yellow : (Color.appAccent)
                )

            VStack(spacing: 8) {
                Text(noReposFound ? "No Repositories Found" : "Ready for a New Batch")
                    .font(.system(.title2))
                    .fontWeight(.black)
                    .foregroundColor(Color.textPrimary)

                Text(limitReachedMessage)
                    .font(.system(.subheadline))
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Batch Summary Card
            VStack(alignment: .leading, spacing: 12) {
                // Batch Counter
                HStack {
                    Image(.inbox)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.appAccent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Batches Used Today")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)

                        Text("\(dailyBatchCount)/\(10)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textPrimary)
                    }

                    Spacer()
                }

                if hasActiveFilters {
                    Divider()
                        .background(Color.textSecondary.opacity(0.3))

                    // Active Filters
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Filters")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)

                        VStack(alignment: .leading, spacing: 6) {
                            if !repoCache.filterCategories.isEmpty {
                                HStack(spacing: 6) {
                                    Image(.tag)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(Color.appAccent)
                                    Text(repoCache.filterCategories.joined(separator: ", "))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.textPrimary)
                                        .lineLimit(2)
                                }
                            }

                            if !repoCache.filterMinStars.isEmpty || !repoCache.filterMaxStars.isEmpty {
                                HStack(spacing: 6) {
                                    Image(.star)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(Color.appAccent)

                                    if !repoCache.filterMinStars.isEmpty && !repoCache.filterMaxStars.isEmpty {
                                        Text("\(repoCache.filterMinStars) - \(repoCache.filterMaxStars) stars")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textPrimary)
                                    } else if !repoCache.filterMinStars.isEmpty {
                                        Text("Min \(repoCache.filterMinStars) stars")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textPrimary)
                                    } else {
                                        Text("Max \(repoCache.filterMaxStars) stars")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textPrimary)
                                    }
                                }
                            }

                            if !repoCache.filterLanguages.isEmpty {
                                HStack(spacing: 6) {
                                    Image(.code)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 12, height: 12)
                                        .foregroundColor(Color.appAccent)
                                    Text(repoCache.filterLanguages.joined(separator: ", "))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.textPrimary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }

                // Expected Repository Count
                if let count = filteredRepoCount {
                    Divider()
                        .background(Color.textSecondary.opacity(0.3))

                    HStack {
                        Image(.document)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(
                                count < 10 ? .yellow : (Color.appAccent)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Batch Size")
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
                }
            }
            .padding(16)
            .background(Color.appBackgroundLight)
            .overlay(
                Rectangle()
                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
            )
            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
            .padding(.horizontal)
            .onAppear {
                updateRepoCount()
            }
            .onChange(of: repoCache.filterCategories) { _, _ in
                updateRepoCount()
            }
            .onChange(of: repoCache.filterMinStars) { _, _ in
                updateRepoCount()
            }
            .onChange(of: repoCache.filterMaxStars) { _, _ in
                updateRepoCount()
            }
            .onChange(of: repoCache.filterLanguages) { _, _ in
                updateRepoCount()
            }

            Button(action: {
                generateNewBatch()
            }) {
                HStack(spacing: 8) {
                    if isGeneratingBatch {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(.refresh)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("GENERATE NEW BATCH")
                            .fontWeight(.black)
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .opacity(isGeneratingBatch ? 0.6 : 1.0)
            }
            .buttonStyle(BrutalistButtonStyle())
            .disabled(isGeneratingBatch)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func updateRepoCount() {
        guard let username = authManager.username else { return }

        repoCache.fetchBatchPreview(username: username) { count in
            self.filteredRepoCount = count
        }
    }
}
