//
//  RepositoryCard.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI
import WebKit

struct RepositoryCard: View {
    let repository: Repository
    let languages: [LanguageInfo]
    let readme: String

    var body: some View {
        VStack(spacing: 0) {
            // Header with repo name and owner
            VStack(alignment: .leading, spacing: 8) {
                Text(repository.name)
                    .font(.system(.title))
                    .fontWeight(.black)
                    .foregroundColor(Color.textPrimary)
                    .padding(.trailing, repository.category != nil ? 80 : 0)

                // Owner and Update Date
                HStack {
                    HStack(spacing: 6) {
                        Image(.user)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundColor(Color.appAccent)
                        Text(repository.ownerName)
                            .font(.system(.subheadline))
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)
                    }

                    Spacer()

                    if let updateDate = repository.repoUpdateDate {
                        HStack(spacing: 4) {
                            Image(.clock)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color.textSecondary.opacity(0.7))
                            Text(formatDate(updateDate))
                                .font(.system(.caption))
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                }

                // Description
                Text(repository.displayDescription)
                    .font(.system(.subheadline))
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .lineLimit(2)
                    .truncationMode(.tail)

                // Stats Row: Watchers, Forks, Stars
                HStack(spacing: 8) {
                    // Watchers
                    HStack(spacing: 6) {
                        Image(.eye)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color.textPrimary)
                        Text(formatCount(repository.watcherCount))
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appBackgroundLighter)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                    )

                    // Forks
                    HStack(spacing: 6) {
                        Image(.fork)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color.textPrimary)
                        Text(formatCount(repository.forkCount))
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appBackgroundLighter)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                    )

                    // Stars
                    HStack(spacing: 6) {
                        Image(.star)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color.starColor)
                        Text(formatCount(repository.stargazersCount))
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appBackgroundLighter)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                    )
                }

                // Language distribution bar
                if !languages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        // Language bar
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                ForEach(languages) { language in
                                    Rectangle()
                                        .fill(Color(hex: language.color))
                                        .frame(width: geometry.size.width * CGFloat(language.percentage / 100))
                                }
                            }
                        }
                        .frame(height: 8)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.brutalistBorder, lineWidth: 1)
                        )

                        // Language labels - horizontally scrollable
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(languages) { language in
                                    HStack(spacing: 4) {
                                        Rectangle()
                                            .fill(Color(hex: language.color))
                                            .frame(width: 10, height: 10)
                                        Text(language.name)
                                            .font(.system(.caption2))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textSecondary)
                                        Text(String(format: "%.1f%%", language.percentage))
                                            .font(.system(.caption2))
                                            .fontWeight(.bold)
                                            .foregroundColor((Color.appAccent).opacity(0.8))
                                    }
                                }
                            }
                            .padding(.trailing, 20)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
            .background(Color.appBackgroundLight)

            // README content
            MarkdownWebView(markdown: readme)
                .frame(maxHeight: .infinity)
                .background(Color.appBackground)
        }
        .background(Color.appBackgroundLight)
        .overlay(
            ZStack(alignment: .top) {
                Rectangle()
                    .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)

                // Category badge attached to top with right spacing
                if let category = repository.category {
                    HStack {
                        Spacer()
                        Text(category)
                            .font(.system(.caption2))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.appAccent)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                            )
                            .padding(.trailing, 12)
                    }
                }
            }
        )
        .brutalistShadow(BrutalistStyle.Shadow.cardPrimary)
    }

    // Format large numbers (1000 -> 1k, 1000000 -> 1M)
    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fk", Double(count) / 1_000)
        } else {
            return "\(count)"
        }
    }

    // Format ISO date string to relative time (e.g., "2 days ago")
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return "Unknown"
        }

        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: now)

        if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 min ago" : "\(minutes) mins ago"
        } else {
            return "Just now"
        }
    }
}





// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    @Previewable @State var selectedView: ContentView.ViewType = .curated
    SwipeView(selectedView: $selectedView)
        .environmentObject(GitHubAuthManager())
}
