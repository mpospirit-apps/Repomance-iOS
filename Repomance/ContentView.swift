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
    
    var body: some View {
        Group {
            if authManager.isAuthenticated || skipAuth {
                SwipeView()
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
