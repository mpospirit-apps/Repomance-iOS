//
//  TrendingHeaderView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingHeaderView: View {
    let hasActiveFilters: Bool
    @Binding var showFilters: Bool
    @Binding var showInfo: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Trending title
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color.appAccent)

                Text("TRENDING")
                    .font(.system(size: 24, weight: .black))
                    .textCase(.uppercase)
                    .foregroundColor(Color.appAccent)
            }

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

            // Info button
            Button(action: {
                showInfo.toggle()
            }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color.textSecondary)
                    .padding(10)
            }
            .buttonStyle(BrutalistIconButtonStyle(size: 44))
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
}
