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
    @EnvironmentObject var themeManager: ThemeManager
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

                            // Time period buttons in flow layout
                            FlowLayout(spacing: 8) {
                                // Today button
                                Button(action: {
                                    if hapticFeedbackEnabled {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }
                                    trendingManager.filterPeriod = .daily
                                }) {
                                    HStack(spacing: 6) {
                                        Image(trendingManager.filterPeriod == .daily ? .checkboxChecked : .checkboxUnchecked)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        Text("Today")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(BrutalistButtonStyle(
                                    backgroundColor: trendingManager.filterPeriod == .daily ? (Color.appAccent) : Color.appBackgroundLight,
                                    foregroundColor: trendingManager.filterPeriod == .daily ? .white : Color.textPrimary,
                                    shadow: .smallBlack
                                ))

                                // This Week button
                                Button(action: {
                                    if hapticFeedbackEnabled {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }
                                    trendingManager.filterPeriod = .weekly
                                }) {
                                    HStack(spacing: 6) {
                                        Image(trendingManager.filterPeriod == .weekly ? .checkboxChecked : .checkboxUnchecked)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        Text("This Week")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(BrutalistButtonStyle(
                                    backgroundColor: trendingManager.filterPeriod == .weekly ? (Color.appAccent) : Color.appBackgroundLight,
                                    foregroundColor: trendingManager.filterPeriod == .weekly ? .white : Color.textPrimary,
                                    shadow: .smallBlack
                                ))

                                // This Month button
                                Button(action: {
                                    if hapticFeedbackEnabled {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }
                                    trendingManager.filterPeriod = .monthly
                                }) {
                                    HStack(spacing: 6) {
                                        Image(trendingManager.filterPeriod == .monthly ? .checkboxChecked : .checkboxUnchecked)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        Text("This Month")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                }
                                .buttonStyle(BrutalistButtonStyle(
                                    backgroundColor: trendingManager.filterPeriod == .monthly ? (Color.appAccent) : Color.appBackgroundLight,
                                    foregroundColor: trendingManager.filterPeriod == .monthly ? .white : Color.textPrimary,
                                    shadow: .smallBlack
                                ))
                            }
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
                        trendingManager.filterPeriod = .weekly
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(.refresh)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                Text("APPLY & REFRESH")
                                    .fontWeight(.black)
                                    .textCase(.uppercase)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .opacity(isLoading ? 0.6 : 1.0)
                    }
                    .buttonStyle(BrutalistButtonStyle(
                        backgroundColor: Color.appAccent
                    ))
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .padding(.top, 8)
                .background(Color.appBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .navigationTitle("Trending Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("TRENDING FILTERS")
                            .font(.system(.headline))
                            .fontWeight(.black)
                            .textCase(.uppercase)
                            .foregroundColor(Color.appAccent)
                    }
                }
            }
            .toolbarBackground(Color.appBackgroundLight, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if hapticFeedbackEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct TrendingLanguage: Identifiable {
    let id = UUID()
    let name: String
    let urlParam: String
}
