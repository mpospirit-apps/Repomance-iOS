//
//  AnnouncementManager.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-23.
//

import Foundation
import SwiftUI
import Combine

class AnnouncementManager: ObservableObject {
    static let shared = AnnouncementManager()

    @Published var announcements: [APIAnnouncement] = []
    @Published var hasUnread: Bool = false
    @Published var isLoading: Bool = false

    private let apiService = CustomAPIService.shared

    private init() {}

    func fetchAnnouncements() {
        isLoading = true
        apiService.fetchAnnouncements { [weak self] result in
            self?.isLoading = false
            if let announcements = result {
                self?.announcements = announcements
                self?.hasUnread = announcements.contains { !$0.is_read }
            }
        }
    }

    func markRead(announcementId: Int) {
        apiService.markAnnouncementRead(announcementId: announcementId) { [weak self] success in
            if success {
                self?.fetchAnnouncements()  // Refresh list
            }
        }
    }
}
