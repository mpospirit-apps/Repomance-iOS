//
//  BatchInfoView.swift
//  Repomance
//
//  Created on 24.12.2025.
//

import SwiftUI

struct BatchInfoView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // How It Works Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How It Works")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            InfoCard(
                                icon: .inbox,
                                title: "Batches",
                                description: "Each batch contains 10 repositories for you to swipe through. You can generate 10 batches per day."
                            )

                            InfoCard(
                                icon: .document,
                                title: "Repositories",
                                description: "Each repository is a unique project. Swipe right to star it on GitHub, or swipe left to pass. The counter shows your current position in the batch."
                            )

                            InfoCard(
                                icon: .clock,
                                title: "Daily Limits",
                                description: "Your batch limit resets daily at midnight UTC. You get 10 batches per day (100 repos total)."
                            )
                        }

                        // Limits Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Limits")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            LimitCard(
                                title: "Daily Batches",
                                value: "10 batches",
                                icon: .inbox
                            )

                            LimitCard(
                                title: "Repos per Batch",
                                value: "10 repositories",
                                icon: .document
                            )

                            LimitCard(
                                title: "Total Daily Repos",
                                value: "100 repositories",
                                icon: .inbox
                            )
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Batch System")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("BATCH SYSTEM")
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
        }
    }
}

// Info Card Component
struct InfoCard: View {
    let icon: AppIcon
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.appAccent)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.appBackgroundLight)
        .overlay(
            Rectangle()
                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
        )
        .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
    }
}

// Limit Card Component
struct LimitCard: View {
    let title: String
    let value: String
    let icon: AppIcon

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.appAccent)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.textPrimary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.appBackgroundLight)
        .overlay(
            Rectangle()
                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
        )
        .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
    }
}
