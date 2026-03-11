//
//  PopupManager.swift
//  Repomance
//

import Foundation
import SwiftUI
import Combine

class PopupManager: ObservableObject {
    static let shared = PopupManager()

    @Published var popupQueue: [APIPopup] = []

    private let apiService = CustomAPIService.shared

    private init() {}

    func fetchPopups() {
        apiService.fetchPopups { [weak self] result in
            guard let self, let popups = result else { return }
            // Queue only unread popups, already ordered by priority desc from backend
            self.popupQueue = popups.filter { !$0.is_read }
        }
    }

    func dismissCurrentPopup() {
        guard let popup = popupQueue.first else { return }
        popupQueue.removeFirst()
        apiService.markPopupRead(popupId: popup.id) { _ in }
    }
}
