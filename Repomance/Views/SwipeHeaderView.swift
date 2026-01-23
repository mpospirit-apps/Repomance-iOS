//
//  SwipeHeaderView.swift
//  Repomance
//
//  Created on 23.12.2025.
//

import SwiftUI

struct SwipeHeaderView: View {
    @Binding var selectedView: ContentView.ViewType
    @EnvironmentObject var authManager: GitHubAuthManager
    let hasActiveFilters: Bool
    let hasUnreadAnnouncements: Bool
    let showFilters: Binding<Bool>
    let showSettings: Binding<Bool>
    let showAnnouncements: Binding<Bool>
    let showStatistics: Binding<Bool>

    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                // Custom dropdown for view selection
                BrutalistDropdown(
                    selectedView: $selectedView,
                    currentTitle: "CURATED"
                )

                Spacer()

                // Announcements button
                Button(action: {
                    showAnnouncements.wrappedValue.toggle()
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(.megaphone)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.textSecondary)

                        // Badge indicator when there are unread announcements
                        if hasUnreadAnnouncements {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.brutalistBorder, lineWidth: 2)
                                )
                                .offset(x: 2, y: -2)
                        }
                    }
                    .padding(10)
                }
                .buttonStyle(BrutalistIconButtonStyle(size: 44))

                // Statistics button
                Button(action: {
                    showStatistics.wrappedValue.toggle()
                }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.textSecondary)
                        .padding(10)
                }
                .buttonStyle(BrutalistIconButtonStyle(size: 44))

                // Filter button
                Button(action: {
                    showFilters.wrappedValue.toggle()
                }) {
                    ZStack(alignment: .topTrailing) {
                        Image(.filter)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.textSecondary)

                        // Badge indicator when filters are active
                        if hasActiveFilters {
                            Rectangle()
                                .fill(Color.appAccent)
                                .frame(width: 8, height: 8)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.brutalistBorder, lineWidth: 2)
                                )
                                .offset(x: 2, y: -2)
                        }
                    }
                    .padding(10)
                }
                .buttonStyle(BrutalistIconButtonStyle(size: 44))

                // Settings button
                Button(action: {
                    showSettings.wrappedValue.toggle()
                }) {
                    Image(.settings)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.textSecondary)
                        .padding(10)
                }
                .buttonStyle(BrutalistIconButtonStyle(size: 44))
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .zIndex(1000)
    }
}