//
//  NoConnectionView.swift
//  Repomance
//
//  Created on 26.12.2025.
//

import SwiftUI

struct NoConnectionView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(.wifiOff)
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color.appAccent)

            VStack(spacing: 8) {
                Text("No Internet Connection")
                    .font(.system(.title2))
                    .fontWeight(.black)
                    .foregroundColor(Color.textPrimary)

                Text("Please check your connection and try again")
                    .font(.system(.subheadline))
                    .fontWeight(.bold)
                    .foregroundColor(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button(action: {
                onRetry()
            }) {
                HStack(spacing: 8) {
                    Image(.refresh)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("RETRY")
                        .fontWeight(.black)
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
            .buttonStyle(BrutalistButtonStyle())
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
