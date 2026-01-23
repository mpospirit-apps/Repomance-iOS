//
//  BrutalistDropdown.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct BrutalistDropdown: View {
    @Binding var selectedView: ContentView.ViewType
    @State private var isExpanded = false

    let currentTitle: String

    var body: some View {
        // Main button
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Text(currentTitle)
                    .font(.system(size: 24, weight: .black))
                    .textCase(.uppercase)
                    .foregroundColor(Color.appAccent)
                    .lineLimit(1)
                    .fixedSize()

                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.appAccent)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .fixedSize()
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(alignment: .topLeading) {
            // Dropdown menu overlay - doesn't affect layout
            if isExpanded {
                VStack(spacing: 0) {
                    // Trending option
                    DropdownMenuItem(
                        title: "TRENDING",
                        isSelected: selectedView == .trending,
                        action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedView = .trending
                                isExpanded = false
                            }
                        }
                    )

                    // Divider
                    Rectangle()
                        .fill(Color.brutalistBorder)
                        .frame(height: BrutalistStyle.borderThin)

                    // Curated option
                    DropdownMenuItem(
                        title: "CURATED",
                        isSelected: selectedView == .curated,
                        action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedView = .curated
                                isExpanded = false
                            }
                        }
                    )
                }
                .frame(width: 220)
                .background(
                    // Shadow first
                    Rectangle()
                        .fill(Color.brutalistShadowBlack)
                        .offset(x: 6, y: 6)
                )
                .background(Color.appBackgroundLight)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                )
                .offset(y: 46)
                .zIndex(999)
                .transition(.opacity)
            }
        }
        .zIndex(isExpanded ? 1000 : 0)
    }
}

struct DropdownMenuItem: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .black))
                    .textCase(.uppercase)
                    .foregroundColor(Color.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.appAccent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isPressed ? Color.appBackgroundLighter : Color.appBackgroundLight)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
