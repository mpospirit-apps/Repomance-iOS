//
//  RepomanceApp.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

@main
struct RepomanceApp: App {
    @StateObject private var authManager = GitHubAuthManager()
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL { url in
                    authManager.handleCallback(url: url)
                }
                .onAppear {
                    authManager.loadToken()
                }
        }
    }
}
