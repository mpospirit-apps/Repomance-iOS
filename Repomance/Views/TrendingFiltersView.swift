//
//  TrendingFiltersView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingFiltersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: GitHubAuthManager
    @StateObject private var trendingManager = TrendingRepoManager.shared
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var isLoading = false
    @Binding var onRefresh: Bool

    // Available languages for filtering
    private let availableLanguages: [TrendingLanguage] = [
        TrendingLanguage(name: "Swift", urlParam: "swift"),
        TrendingLanguage(name: "JavaScript", urlParam: "javascript"),
        TrendingLanguage(name: "TypeScript", urlParam: "typescript"),
        TrendingLanguage(name: "Python", urlParam: "python"),
        TrendingLanguage(name: "Java", urlParam: "java"),
        TrendingLanguage(name: "Kotlin", urlParam: "kotlin"),
        TrendingLanguage(name: "Go", urlParam: "go"),
        TrendingLanguage(name: "Rust", urlParam: "rust"),
        TrendingLanguage(name: "Ruby", urlParam: "ruby"),
        TrendingLanguage(name: "C++", urlParam: "c++"),
        TrendingLanguage(name: "C", urlParam: "c"),
        TrendingLanguage(name: "C#", urlParam: "c#"),
        TrendingLanguage(name: "PHP", urlParam: "php"),
        TrendingLanguage(name: "Dart", urlParam: "dart")
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Time Period Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Period")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            Picker("Period", selection: $trendingManager.filterPeriod) {
                                Text("Daily").tag(TrendingPeriod.daily)
                                Text("Weekly").tag(TrendingPeriod.weekly)
                                Text("Monthly").tag(TrendingPeriod.monthly)
                            }
                            .pickerStyle(.segmented)
                            .background(Color.appBackgroundLight)
                            .cornerRadius(0)
                        }

                        // Language Filter
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Language")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            // All Languages button
                            Button(action: {
                                if hapticFeedbackEnabled {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                                trendingManager.filterLanguage = nil
                            }) {
                                HStack(spacing: 6) {
                                    Image(trendingManager.filterLanguage == nil ? .checkboxChecked : .checkboxUnchecked)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                    Text("All Languages")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(BrutalistButtonStyle(
                                backgroundColor: trendingManager.filterLanguage == nil ? (Color.appAccent) : Color.appBackgroundLight,
                                foregroundColor: trendingManager.filterLanguage == nil ? .white : Color.textPrimary,
                                shadow: .smallBlack
                            ))

                            // Language buttons in flow layout
                            FlowLayout(spacing: 8) {
                                ForEach(availableLanguages) { language in
                                    Button(action: {
                                        if hapticFeedbackEnabled {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                        }

                                        if trendingManager.filterLanguage == language.urlParam {
                                            trendingManager.filterLanguage = nil
                                        } else {
                                            trendingManager.filterLanguage = language.urlParam
                                        }
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(trendingManager.filterLanguage == language.urlParam ? .checkboxChecked : .checkboxUnchecked)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                            Text(language.name)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                    }
                                    .buttonStyle(BrutalistButtonStyle(
                                        backgroundColor: trendingManager.filterLanguage == language.urlParam ? (Color.appAccent) : Color.appBackgroundLight,
                                        foregroundColor: trendingManager.filterLanguage == language.urlParam ? .white : Color.textPrimary,
                                        shadow: .smallBlack
                                    ))
                                }
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }

                // Buttons - Fixed at bottom
                VStack(spacing: 12) {
                    // Clear Filters Button
                    Button(action: {
                        if hapticFeedbackEnabled {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                        trendingManager.filterLanguage = nil
                        trendingManager.filterPeriod = .daily
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("CLEAR FILTERS")
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(BrutalistButtonStyle(
                        backgroundColor: Color.appBackgroundLight,
                        foregroundColor: Color.textPrimary,
                        shadow: .cardBlack
                    ))

                    // Apply & Refresh Button
                    Button(action: {
                        if hapticFeedbackEnabled {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        }
                        onRefresh = true
                        dismiss()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("APPLY & REFRESH")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(BrutalistButtonStyle(
                        backgroundColor: Color.appAccent,
                        foregroundColor: .white,
                        shadow: .cardBlack
                    ))
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .navigationTitle("Trending Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                    }
                }
            }
        }
    }
}

struct TrendingLanguage: Identifiable {
    let id = UUID()
    let name: String
    let urlParam: String
}
