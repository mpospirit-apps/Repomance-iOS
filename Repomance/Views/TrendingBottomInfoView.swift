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
        HStack(spacing: 8) {
            // Period badge
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10, weight: .bold))
                Text(selectedPeriod.rawValue.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.appAccent)
            .foregroundColor(.white)
            .overlay(
                Rectangle()
                    .stroke(Color.brutalistBorder, lineWidth: 2)
            )

            // Language badge (if filtered)
            if let language = selectedLanguage {
                HStack(spacing: 4) {
                    Image(.code)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    Text(language.uppercased())
                        .font(.system(size: 11, weight: .black))
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.appBackgroundLight)
                .foregroundColor(Color.textPrimary)
                .overlay(
                    Rectangle()
                        .stroke(Color.brutalistBorder, lineWidth: 2)
                )
            }

            Spacer()

            // Remaining count
            HStack(spacing: 4) {
                Text("\(remainingCount)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Color.appAccent)
                Image(.document)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(Color.appAccent)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.appBackground.opacity(0.95))
    }
}
