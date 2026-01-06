//
//  Colors.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 8.12.2025.
//

import SwiftUI

extension Color {
    // Helper initializer for adaptive colors (light/dark mode)
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // GitHub Color Scheme - ADAPTIVE (Light & Dark)
    static let appBackground = Color(
        light: Color(hex: "#ffffff"),
        dark: Color(hex: "#0D1117")
    )
    static let appBackgroundLight = Color(
        light: Color(hex: "#f6f8fa"),
        dark: Color(hex: "#161B22")
    )
    static let appBackgroundLighter = Color(
        light: Color(hex: "#e5e8eb"),
        dark: Color(hex: "#21262D")
    )
    static let appAccent = Color(hex: "#1F6FEB")            // Primary accent color
    static let appAccentSecondary = Color(hex: "#7a2dfa")   // Secondary accent color

    // Text colors - ADAPTIVE
    static let starColor = Color(
        light: Color(hex: "#ca9650"),
        dark: Color(hex: "#E3B341")
    )
    static let passColor = Color(
        light: Color(hex: "#d16669"),
        dark: Color(hex: "#F47067")
    )
    static let textPrimary = Color(
        light: Color(hex: "#24292f"),
        dark: Color(hex: "#E6EDF3")
    )
    static let textSecondary = Color(
        light: Color(hex: "#57606a"),
        dark: Color(hex: "#8B949E")
    )
    static let textTertiary = Color(
        light: Color(hex: "#656d76"),
        dark: Color(hex: "#6E7681")
    )

    // NEOBRUTALISM COLORS - ADAPTIVE
    static let brutalistBorder = Color(
        light: Color(hex: "#000000"),
        dark: Color(hex: "#30363D")
    )

    // Shadow colors (solid, no blur) - ADAPTIVE
    static let brutalistShadowPrimary = Color.appAccent      // #1F6FEB
    static let brutalistShadowSecondary = Color.appAccentSecondary  // #7a2dfa
    static let brutalistShadowBlack = Color(
        light: Color(hex: "#000000"),
        dark: Color(hex: "#30363D")
    )
}

// NEOBRUTALISM STYLE CONSTANTS
struct BrutalistStyle {
    // Border widths
    static let borderThin: CGFloat = 3
    static let borderThick: CGFloat = 4

    // Corner radius (ZERO for true brutalism)
    static let cornerRadius: CGFloat = 0

    // Shadow offsets (NO BLUR)
    struct Shadow {
        let offsetX: CGFloat
        let offsetY: CGFloat
        let color: Color
        let pressedOffsetX: CGFloat
        let pressedOffsetY: CGFloat
        let pressedColor: Color

        init(offsetX: CGFloat, offsetY: CGFloat, color: Color, pressedOffsetX: CGFloat? = nil, pressedOffsetY: CGFloat? = nil, pressedColor: Color? = nil) {
            self.offsetX = offsetX
            self.offsetY = offsetY
            self.color = color
            // Default pressed offset is 2/3 of the original offset (push toward shadow)
            self.pressedOffsetX = pressedOffsetX ?? (offsetX * 2 / 3)
            self.pressedOffsetY = pressedOffsetY ?? (offsetY * 2 / 3)
            // Default pressed color is slightly darker
            self.pressedColor = pressedColor ?? color.opacity(0.8)
        }

        // Card shadows
        static let cardPrimary = Shadow(offsetX: 8, offsetY: 8, color: .brutalistShadowPrimary)
        static let cardBlack = Shadow(offsetX: 6, offsetY: 6, color: .brutalistShadowBlack)

        // Button shadows
        static let button = Shadow(offsetX: 6, offsetY: 6, color: .brutalistShadowBlack, pressedOffsetX: 2, pressedOffsetY: 2)
        static let buttonPressed = Shadow(offsetX: 2, offsetY: 2, color: .brutalistShadowBlack)

        // Small element shadows
        static let small = Shadow(offsetX: 4, offsetY: 4, color: .brutalistShadowPrimary, pressedOffsetX: 2, pressedOffsetY: 2)
        static let smallBlack = Shadow(offsetX: 3, offsetY: 3, color: .brutalistShadowBlack, pressedOffsetX: 1, pressedOffsetY: 1)
    }

    // Typography weights
    static let fontWeightBold: Font.Weight = .heavy  // 800-900
    static let fontWeightNormal: Font.Weight = .bold  // 700
}
