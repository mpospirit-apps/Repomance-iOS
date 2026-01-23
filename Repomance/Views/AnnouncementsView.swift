//
//  AnnouncementsView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-23.
//

import SwiftUI

struct AnnouncementsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var announcementManager = AnnouncementManager.shared
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    @State private var isLoading = true
    @State private var hasError = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                if isLoading {
                    loadingView
                } else if hasError {
                    errorView
                } else if announcementManager.announcements.isEmpty {
                    emptyStateView
                } else {
                    announcementsList
                }
            }
            .navigationTitle("Announcements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("ANNOUNCEMENTS")
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
            loadAnnouncements()
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.appAccent))
                .scaleEffect(1.5)
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(.wifiOff)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(Color.textSecondary)

            Text("Failed to Load Announcements")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(Color.textPrimary)

            Text("Please check your connection and try again.")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                loadAnnouncements()
            }) {
                HStack {
                    Image(.refresh)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("RETRY")
                        .fontWeight(.black)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .buttonStyle(BrutalistButtonStyle(backgroundColor: Color.appAccent))
        }
        .padding(32)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(.megaphone)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(Color.textSecondary)

            Text("No Announcements")
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(Color.textPrimary)

            Text("Check back later for updates and news.")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private var announcementsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Click the cards to mark them as read")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)

                ForEach(announcementManager.announcements) { announcement in
                    AnnouncementCard(announcement: announcement) {
                        // Mark as read when tapped
                        announcementManager.markRead(announcementId: announcement.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    private func loadAnnouncements() {
        isLoading = true
        hasError = false

        announcementManager.fetchAnnouncements()

        // Wait a bit for the fetch to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            // Check if we got announcements or error
            if announcementManager.announcements.isEmpty && !announcementManager.isLoading {
                // Could be either empty or error - we'll show empty state
                hasError = false
            }
        }
    }
}

// MARK: - Announcement Card

struct AnnouncementCard: View {
    let announcement: APIAnnouncement
    let onTap: () -> Void

    private var typeColor: Color {
        if announcement.is_read {
            return Color.textSecondary
        }
        return Color(hex: announcement.announcement_type.color) ?? Color.appAccent
    }

    private var backgroundColor: Color {
        announcement.is_read ? Color.textSecondary.opacity(0.1) : Color.appBackgroundLight
    }

    private var textColor: Color {
        announcement.is_read ? Color.textSecondary : Color.textPrimary
    }

    private var typeIcon: AppIcon {
        switch announcement.announcement_type.icon {
        case "warning":
            return .warning
        case "star":
            return .star
        case "gift":
            return .gift
        case "bug":
            return .bug
        case "flag":
            return .flag
        case "megaphone":
            return .megaphone
        default:
            return .megaphone
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                    // Header with type icon
                    HStack(spacing: 8) {
                        Image(typeIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(typeColor)

                        Text(announcement.announcement_type.display_name.uppercased())
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(typeColor)

                        Spacer()

                        Text(formatDate(announcement.created_at))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)

                        // Read indicator
                        if announcement.is_read {
                            Image(.checkboxChecked)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                                .foregroundColor(Color.textSecondary)
                        }
                    }

                    // Title
                    Text(announcement.title)
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)

                    // Content
                    Text(announcement.content)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .background(
                    Rectangle()
                        .fill(backgroundColor)
                )
                .overlay(
                    Rectangle()
                        .stroke(typeColor, lineWidth: 3)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func formatDate(_ dateString: String) -> String {
        // If already in YYYY-MM-DD format, return as-is
        if dateString.range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil {
            return dateString
        }

        // Try parsing as ISO8601 full timestamp (fallback for backward compatibility)
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd"
        return displayFormatter.string(from: date)
    }
}

#Preview {
    AnnouncementsView()
        .environmentObject(ThemeManager())
}
