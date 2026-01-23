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
    @StateObject private var announcementManager = AnnouncementManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(announcementManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL { url in
                    authManager.handleCallback(url: url)
                }
                .onAppear {
                    authManager.loadToken()
                    // Check for unread announcements on app open
                    announcementManager.fetchAnnouncements()
                }
        }
    }
}
