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
    @State private var selectedView: ViewType = .curated

    enum ViewType {
        case curated
        case trending
    }

    var body: some View {
        Group {
            if authManager.isAuthenticated || skipAuth {
                ZStack {
                    if selectedView == .curated {
                        SwipeView(selectedView: $selectedView)
                    } else {
                        TrendingView(selectedView: $selectedView)
                    }
                }
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
