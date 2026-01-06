//
//  ThemeManager.swift
//  Repomance
//
//  Theme management for Light/Dark/System modes
//

import SwiftUI
import Combine

enum ThemeMode: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: String {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
            updateColorScheme()
        }
    }

    @Published var colorScheme: ColorScheme? = nil

    var currentTheme: ThemeMode {
        ThemeMode(rawValue: selectedTheme) ?? .system
    }

    init() {
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? ThemeMode.system.rawValue
        updateColorScheme()
    }

    private func updateColorScheme() {
        switch currentTheme {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil  // Let system decide
        }
    }
}
