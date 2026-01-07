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
    let showToast: Bool
    let toastMessage: String?
    let toastColor: Color
    let swipeProgress: CGFloat

    private var bottomOffset: CGFloat {
        // Move the counters down as the card is swiped
        // For successful swipes (abs > 1), continue moving down and away
        let maxOffset: CGFloat = 30
        let absProgress = abs(swipeProgress)

        if absProgress > 1.0 {
            // Card is being swiped away - move counters further down
            let extraMovement = (absProgress - 1.0) * 100 // Amplify movement during swipe away
            return maxOffset + extraMovement
        } else {
            // Normal drag gesture - gradual movement
            return absProgress * maxOffset
        }
    }

    var body: some View {
        Group {
            if showToast, let message = toastMessage {
                // Show notification - match count area height exactly with proper centering
                HStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(toastColor)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 28 + 8) // Match count area content height (2 lines + spacing)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.appBackgroundLight)
                .overlay(
                    Rectangle()
                        .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
                )
                .brutalistShadow(BrutalistStyle.Shadow.smallBlack)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ).animation(.easeOut(duration: 0.4)))
            } else {
                // Show info
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

                    // Language Section
                    VStack(spacing: 4) {
                        Text("Language")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.textSecondary)
                        Text(selectedLanguage ?? "all")
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
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ).animation(.easeOut(duration: 0.4)))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .offset(y: bottomOffset)
        .animation(.easeOut(duration: 0.4), value: showToast)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8), value: swipeProgress)
    }
}
