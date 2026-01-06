//
//  ContentView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @State private var skipAuth = false
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if authManager.isAuthenticated || skipAuth {
                TabView(selection: $selectedTab) {
                    SwipeView()
                        .tabItem {
                            Label("Curated", systemImage: "star.fill")
                        }
                        .tag(0)

                    TrendingView()
                        .tabItem {
                            Label("Trending", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(1)
                }
                .accentColor(Color.appAccent)
            } else {
                LandingView(isAuthenticated: $authManager.isAuthenticated, skipAuth: $skipAuth)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GitHubAuthManager())
}
