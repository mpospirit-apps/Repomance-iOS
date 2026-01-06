//
//  TrendingBottomInfoView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingBottomInfoView: View {
    let remainingCount: Int
    let selectedPeriod: TrendingPeriod
    let selectedLanguage: String?

    var body: some View {
        HStack(spacing: 0) {
            // Period Section
            VStack(spacing: 4) {
                Text("Period")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.textSecondary)
                Text(selectedPeriod.rawValue.capitalized)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)

            // Divider
            Rectangle()
                .fill(Color.textSecondary.opacity(0.2))
                .frame(width: 1, height: 28)
                .padding(.horizontal, 8)

            // Language/Remaining Section
            VStack(spacing: 4) {
                Text(selectedLanguage != nil ? "Language" : "Remaining")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.textSecondary)
                Text(selectedLanguage ?? "\(remainingCount)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(Color.appBackgroundLight)
        .overlay(
            Rectangle()
                .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
        )
        .brutalistShadow(BrutalistStyle.Shadow.smallBlack)
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}
