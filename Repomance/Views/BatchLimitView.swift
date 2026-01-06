//
//  BatchLimitView.swift
//  Repomance
//
//  Created on 23.12.2025.
//

import SwiftUI

struct BatchLimitView: View {
    let dailyBatchCount: Int
    let remainingTime: String

    var body: some View {
        VStack(spacing: 24) {
            Image(.meditation)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color.appAccent)

            VStack(spacing: 8) {
                Text("Daily Limit Reached")
                    .font(.system(.title2))
                    .fontWeight(.black)
                    .foregroundColor(Color.textPrimary)

                Text("You've used all 10 daily batch requests. Come back in \(remainingTime) for more!")
                    .font(.system(.subheadline))
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
