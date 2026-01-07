//
//  TrendingHeaderView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingHeaderView: View {
    @Binding var selectedView: ContentView.ViewType
    let hasActiveFilters: Bool
    @Binding var showFilters: Bool
    @Binding var showSettings: Bool

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                // Custom dropdown for view selection
                BrutalistDropdown(
                    selectedView: $selectedView,
                    currentTitle: "TRENDING",
                    currentIcon: "system:chart.line.uptrend.xyaxis"
                )

                Spacer()

                // Filter button
                Button(action: {
                    showFilters.toggle()
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
                    showSettings.toggle()
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
