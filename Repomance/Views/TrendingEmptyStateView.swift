//
//  TrendingEmptyStateView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingEmptyStateView: View {
    @ObservedObject var trendingManager = TrendingRepoManager.shared
    let isLoading: Bool
    let loadTrending: () -> Void
    let errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: errorMessage != nil ? "magnifyingglass" : "chart.line.uptrend.xyaxis")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(errorMessage != nil ? .yellow : (Color.appAccent))

            VStack(spacing: 8) {
                Text(errorMessage != nil ? "No Trending Repos Found" : "Ready for Trending Repos")
                    .font(.system(.title2))
                    .fontWeight(.black)
                    .foregroundColor(Color.textPrimary)

                Text(errorMessage ?? "Load trending to discover popular repositories")
                    .font(.system(.subheadline))
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Filter Summary Card
            VStack(alignment: .leading, spacing: 12) {
                // Filters Header
                HStack {
                    Image(.filter)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.appAccent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Filters")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)
                    }

                    Spacer()
                }

                Divider()
                    .background(Color.textSecondary.opacity(0.3))

                // Active Filters
                VStack(alignment: .leading, spacing: 6) {
                    // Period
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.appAccent)
                        Text(trendingManager.filterPeriod.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textPrimary)
                    }

                    // Language
                    HStack(spacing: 6) {
                        Image(.code)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color.appAccent)
                        Text(trendingManager.filterLanguage?.capitalized ?? "All Languages")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textPrimary)
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

            Button(action: {
                print("🔘 [TrendingEmptyStateView] LOAD TRENDING button pressed")
                loadTrending()
            }) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("LOAD TRENDING")
                            .fontWeight(.black)
                            .textCase(.uppercase)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .opacity(isLoading ? 0.6 : 1.0)
            }
            .buttonStyle(BrutalistButtonStyle())
            .disabled(isLoading)
            .padding(.horizontal)

            // Info text
            Text("No daily limits • Unlimited browsing")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
