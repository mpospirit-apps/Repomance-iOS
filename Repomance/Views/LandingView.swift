//
//  LandingView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 8.12.2025.
//

import SwiftUI

struct LandingView: View {
    @Binding var isAuthenticated: Bool
    @Binding var skipAuth: Bool
    @EnvironmentObject var authManager: GitHubAuthManager
    
    var body: some View {
        ZStack {
            // GitHub Dark Theme background
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo/Title Section
                VStack(spacing: 16) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    
                    Text("REPOMANCE")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(Color.appAccent)

                    Text("DISCOVER & STAR REPOS")
                        .font(.system(.title3))
                        .fontWeight(.heavy)
                        .foregroundColor(Color.textSecondary)
                }
                
                // GitHub Auth Button
                Button(action: {
                    authManager.startOAuthFlow()
                }) {
                    HStack(spacing: 12) {
                        Image(.github)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("LOGIN WITH GITHUB")
                            .font(.system(.headline))
                            .fontWeight(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                }
                .buttonStyle(BrutalistButtonStyle())
                .padding(.horizontal, 32)

                // Reason for OAuth
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(.lock)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(Color.appAccent)

                        Text("Why Repomance needs public repository access")
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)
                    }

                    Text("GitHub's API requires user-level authentication to star repositories. Repomance requests only public_repo scope (the minimum permission needed to star on your behalf). Your token never touches private repositories or sensitive account data.")
                        .font(.system(.subheadline))
                        .fontWeight(.bold)
                        .foregroundColor(Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.appBackgroundLight)
                .overlay(
                    Rectangle()
                        .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                )
                .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                .padding(.horizontal, 32)
                }
                .padding(.horizontal, 32)
            }
        }
    }


#Preview {
    LandingView(isAuthenticated: .constant(false), skipAuth: .constant(false))
        .environmentObject(GitHubAuthManager())
}
