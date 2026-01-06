//
//  AboutView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 10.12.2025.
//

import SwiftUI
import SafariServices

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var userStats: UserStats?
    @State private var isLoadingStats = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // User Statistics Section
                        if isLoadingStats {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.appAccent))
                                Text("Loading your stats...")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else if let stats = userStats {
                            VStack(spacing: 16) {
                                Text("Your Statistics")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Stats Grid
                                VStack(spacing: 12) {
                                    // Star vs Pass Bar Chart
                                    VStack(spacing: 8) {
                                        HStack(spacing: 0) {
                                            Text("Stars vs Passes")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.textSecondary)
                                            Spacer()
                                        }

                                        GeometryReader { geometry in
                                            HStack(spacing: 0) {
                                                let total = stats.starsCount + stats.skipsCount
                                                let starPercentage = total > 0 ? CGFloat(stats.starsCount) / CGFloat(total) : 0.5
                                                let passPercentage = total > 0 ? CGFloat(stats.skipsCount) / CGFloat(total) : 0.5

                                                // Stars section
                                                Rectangle()
                                                    .fill(Color.appAccent)
                                                    .frame(width: geometry.size.width * starPercentage)

                                                // Passes section
                                                Rectangle()
                                                    .fill(Color.textSecondary.opacity(0.5))
                                                    .frame(width: geometry.size.width * passPercentage)
                                            }
                                        }
                                        .frame(height: 24)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                                        )

                                        HStack(spacing: 0) {
                                            HStack(spacing: 4) {
                                                Rectangle()
                                                    .fill(Color.appAccent)
                                                    .frame(width: 8, height: 8)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.brutalistBorder, lineWidth: 1)
                                                    )
                                                Text("\(stats.starsCount) stars")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.textSecondary)
                                            }
                                            Spacer()
                                            HStack(spacing: 4) {
                                                Text("\(stats.skipsCount) passes")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.textSecondary)
                                                Rectangle()
                                                    .fill(Color.textSecondary.opacity(0.5))
                                                    .frame(width: 8, height: 8)
                                                    .overlay(
                                                        Rectangle()
                                                            .stroke(Color.brutalistBorder, lineWidth: 1)
                                                    )
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

                                    // First Row
                                    GeometryReader { geometry in
                                        let spacing: CGFloat = 16
                                        let totalWidth = geometry.size.width
                                        let swipesWidth = (totalWidth - spacing) * 0.4
                                        let typeWidth = (totalWidth - spacing) * 0.6

                                        HStack(spacing: spacing) {
                                            StatCard(
                                                title: "All Swipes",
                                                value: "\(stats.totalInteractions)",
                                                icon: .handTap
                                            )
                                            .frame(width: swipesWidth)

                                            // User Type Card
                                            let userType = getUserType(stars: stats.starsCount, passes: stats.skipsCount)
                                            StatCard(
                                                title: "Type",
                                                value: userType.name,
                                                icon: userType.icon,
                                            )
                                            .frame(width: typeWidth)
                                        }
                                    }
                                    .frame(height: 120)

                                    // Second Row
                                    GeometryReader { geometry in
                                        let spacing: CGFloat = 16
                                        let totalWidth = geometry.size.width
                                        let itemWidth = (totalWidth - (spacing * 2)) / 3

                                        HStack(spacing: spacing) {
                                            // Star Rate
                                            let total = stats.starsCount + stats.skipsCount
                                            let starRate = total > 0 ? Int(Double(stats.starsCount) / Double(total) * 100) : 0
                                            StatCard(
                                                title: "Star Rate",
                                                value: "\(starRate)%",
                                                icon: .percent
                                            )
                                            .frame(width: itemWidth)

                                            // Daily Batches
                                            let maxBatches = 10
                                            StatCard(
                                                title: "Today's Batches",
                                                value: "\(stats.dailyBatchCount)/\(maxBatches)",
                                                icon: .calendar
                                            )
                                            .frame(width: itemWidth)

                                            // Selectivity Score
                                            let selectivity = stats.starsCount > 0 ? Double(stats.totalInteractions) / Double(stats.starsCount) : 0
                                            let selectivityDisplay = selectivity > 0 ? String(format: "%.1f", selectivity) : "—"
                                            StatCard(
                                                title: "Swipes/Star",
                                                value: selectivityDisplay,
                                                icon: .chart
                                            )
                                            .frame(width: itemWidth)
                                        }
                                    }
                                    .frame(height: 120)
                                }
                            }
                            .padding(.vertical, 8)
                        }

                        Divider()
                            .background(Color.textSecondary.opacity(0.3))
                            .padding(.vertical, 8)

                        // Links Section
                        HStack(spacing: 8) {
                            Button(action: {
                                openURL(URL(string: "https://repomance.com/privacy")!)
                            }) {
                                Text("Privacy Policy")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }

                            Text("|")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary.opacity(0.5))

                            Button(action: {
                                openURL(URL(string: "https://repomance.com/license")!)
                            }) {
                                Text("License")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }

                            Text("|")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary.opacity(0.5))

                            Button(action: {
                                openURL(URL(string: "https://repomance.com/support")!)
                            }) {
                                Text("Support")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                        // About Section
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("Made with")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textPrimary)
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(Color.appAccent)
                                Text("by")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textPrimary)
                            }
                            Button(action: {
                                openURL(URL(string: "https://www.cagrigokpunar.com")!)
                            }) {
                                Text("Çağrı \"mpospirit\" Gökpunar")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .onAppear {
                    loadUserStats()
                }
            }
            .navigationTitle("Repomance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("REPOMANCE")
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

    private func loadUserStats() {
        guard let userId = authManager.userId else {
            isLoadingStats = false
            return
        }

        CustomAPIService.shared.fetchUserStats(userId: userId) { stats in
            DispatchQueue.main.async {
                self.userStats = stats
                self.isLoadingStats = false
            }
        }
    }

    private func getUserType(stars: Int, passes: Int) -> (name: String, icon: AppIcon) {
        let total = stars + passes
        guard total > 0 else {
            return ("Explorer", .sparkles)
        }

        let starPercentage = Double(stars) / Double(total) * 100

        switch starPercentage {
        case 80...100:
            return ("Collector", .stack)
        case 60..<80:
            return ("Enthusiast", .starCircle)
        case 40..<60:
            return ("Balanced", .scale)
        case 20..<40:
            return ("Selective", .eye)
        default: // 0..<20
            return ("Perfectionist", .sparkleSearch)
        }
    }

    private func openURL(_ url: URL) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                var topController = window.rootViewController
                while let presented = topController?.presentedViewController {
                    topController = presented
                }

                let safariVC = SFSafariViewController(url: url)
                topController?.present(safariVC, animated: true)
            }
        }
    }
}

// Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: AppIcon

    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.appAccent)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 16)
        .background(Color.appBackgroundLight)
        .overlay(
            Rectangle()
                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
        )
        .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
    }
}

#Preview {
    AboutView()
}
