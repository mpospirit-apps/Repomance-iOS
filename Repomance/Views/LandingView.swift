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

                    Text("Discover and Star Repos")
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

                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Repomance is open source")
                                .font(.system(.headline))
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            HStack(spacing: 4) {
                                Text("Check")
                                    .font(.system(.subheadline))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)

                                Link("GitHub repository", destination: URL(string: "https://github.com/mpospirit-apps/Repomance-iOS")!)
                                    .font(.system(.subheadline))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                    }

                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .font(.system(.headline))
                            .fontWeight(.heavy)
                            .foregroundColor(Color.textPrimary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Why Repomance needs public repository access")
                                .font(.system(.headline))
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            Text("GitHub requires authentication to star repositories. Repomance only requests public_repo access - the minimum permission needed to star on your behalf.")
                                .font(.system(.subheadline))
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
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
