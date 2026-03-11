//
//  ContentView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var popupManager: PopupManager
    @State private var skipAuth = false
    @State private var selectedView: ViewType = .trending

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

                    // Popup overlay — shown when there are unread active popups
                    if let popup = popupManager.popupQueue.first {
                        PopupView(popup: popup)
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
