//
//  Icons.swift
//  Repomance
//
//  Created on 29.12.2025.
//

import SwiftUI

/// Centralized icon names for the app
/// All icons are from Streamline sharp solid icon set
enum AppIcon: String {
    // Actions
    case star = "icon-star"
    case close = "icon-close"
    case closeCircle = "icon-close-circle"
    case refresh = "icon-refresh"
    case logout = "icon-logout"

    // UI Elements
    case filter = "icon-filter"
    case settings = "icon-settings"
    case checkboxChecked = "icon-check"
    case checkboxUnchecked = "icon-square"

    // Status Indicators
    case flame = "icon-flame"
    case lock = "icon-lock"
    case alert = "icon-alert"
    case warning = "icon-warning"
    case wifiOff = "icon-wifi-off"

    // Content Types
    case document = "icon-document"
    case tag = "icon-tag"
    case code = "icon-code"
    case inbox = "icon-inbox"
    case search = "icon-search"

    // Repository Info
    case user = "icon-user"
    case clock = "icon-clock"
    case eye = "icon-eye"
    case fork = "icon-fork"
    case github = "icon-github"

    // Premium/Features
    case heart = "icon-heart"
    case dollar = "icon-dollar"
    case calendar = "icon-calendar"
    case meditation = "icon-meditation"
    case userCheck = "icon-user-check"

    // Statistics
    case handTap = "icon-hand-tap"
    case starCircle = "icon-star-circle"
    case sparkles = "icon-sparkles"
    case chart = "icon-chart"
    case percent = "icon-percent"
    case scale = "icon-scale"
    case stack = "icon-stack"
    case sparkleSearch = "icon-sparkle-search"

    var image: Image {
        Image(self.rawValue)
    }
}

extension Image {
    /// Creates an image from AppIcon enum
    init(_ icon: AppIcon) {
        self.init(icon.rawValue)
    }
}
