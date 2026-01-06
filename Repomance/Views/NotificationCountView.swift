//
//  NotificationCountView.swift
//  Repomance
//
//  Created on 23.12.2025.
//

import SwiftUI

struct NotificationCountView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    let showToast: Bool
    let toastMessage: String?
    let toastColor: Color
    let repoCache: RepoCache
    let dailyBatchCount: Int
    let swipeProgress: CGFloat
    @Binding var showBatchInfo: Bool
    @State private var isPressed: Bool = false

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
                // Show counts
                HStack(spacing: 0) {
                    // Repo Section
                    VStack(spacing: 4) {
                        Text("Repo")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.textSecondary)
                        Text("\(repoCache.currentPosition)/\(repoCache.batchSize)")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    // Divider
                    Rectangle()
                        .fill(Color.textSecondary.opacity(0.2))
                        .frame(width: 1, height: 28)
                        .padding(.horizontal, 8)
                    // Batch Section
                    VStack(spacing: 4) {
                        Text("Batch")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.textSecondary)
                        Text("\(dailyBatchCount)/\(10)")
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
                .background(
                    // Shadow that counter-moves to stay fixed in absolute position
                    Rectangle()
                        .fill(BrutalistStyle.Shadow.smallBlack.color)
                        .offset(
                            x: BrutalistStyle.Shadow.smallBlack.offsetX - (isPressed ? BrutalistStyle.Shadow.smallBlack.pressedOffsetX : 0),
                            y: BrutalistStyle.Shadow.smallBlack.offsetY - (isPressed ? BrutalistStyle.Shadow.smallBlack.pressedOffsetY : 0)
                        )
                )
                .offset(
                    x: isPressed ? BrutalistStyle.Shadow.smallBlack.pressedOffsetX : 0,
                    y: isPressed ? BrutalistStyle.Shadow.smallBlack.pressedOffsetY : 0
                )
                .animation(.easeOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    showBatchInfo = true
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isPressed = true
                        }
                        .onEnded { _ in
                            isPressed = false
                            showBatchInfo = true
                        }
                )
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