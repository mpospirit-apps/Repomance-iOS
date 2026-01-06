//
//  SwipeHeaderView.swift
//  Repomance
//
//  Created on 23.12.2025.
//

import SwiftUI

struct SwipeHeaderView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    let hasActiveFilters: Bool
    let showAbout: Binding<Bool>
    let showFilters: Binding<Bool>
    let showSettings: Binding<Bool>

    var body: some View {
        HStack(spacing: 12) {
            // Title button
            Button(action: {
                showAbout.wrappedValue.toggle()
            }) {
                HStack(spacing: 8) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)

                    Text("REPOMANCE")
                        .font(.system(size: 24, weight: .black))
                        .textCase(.uppercase)
                        .foregroundColor(Color.appAccent)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Spacer()

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
}