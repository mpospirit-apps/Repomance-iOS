//
//  BrutalistModifiers.swift
//  Repomance
//
//  Created for Neobrutalism UI transformation
//

import SwiftUI

// MARK: - Hard Shadow Modifier
struct BrutalistShadow: ViewModifier {
    let shadow: BrutalistStyle.Shadow

    func body(content: Content) -> some View {
        content
            .background(
                Rectangle()
                    .fill(shadow.color)
                    .offset(x: shadow.offsetX, y: shadow.offsetY)
            )
    }
}

// MARK: - Brutalist Card Modifier
struct BrutalistCard: ViewModifier {
    let borderColor: Color
    let shadowType: BrutalistStyle.Shadow
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .overlay(
                Rectangle()
                    .strokeBorder(borderColor, lineWidth: BrutalistStyle.borderThick)
            )
            .modifier(BrutalistShadow(shadow: shadowType))
    }
}

// MARK: - Brutalist Button Style
struct BrutalistButtonStyle: ButtonStyle {
    let backgroundColor: Color?
    let foregroundColor: Color
    let shadow: BrutalistStyle.Shadow

    init(
        backgroundColor: Color? = nil,
        foregroundColor: Color = .white,
        shadow: BrutalistStyle.Shadow = .button
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.shadow = shadow
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foregroundColor)
            .background(backgroundColor ?? Color.appAccent)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
            )
            .background(
                // Shadow that counter-moves to stay fixed in absolute position
                Rectangle()
                    .fill(shadow.color)
                    .offset(
                        x: shadow.offsetX - (configuration.isPressed ? shadow.pressedOffsetX : 0),
                        y: shadow.offsetY - (configuration.isPressed ? shadow.pressedOffsetY : 0)
                    )
            )
            .offset(
                x: configuration.isPressed ? shadow.pressedOffsetX : 0,
                y: configuration.isPressed ? shadow.pressedOffsetY : 0
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Brutalist Icon Button Style (for icon-only buttons)
struct BrutalistIconButtonStyle: ButtonStyle {
    let size: CGFloat
    let shadow: BrutalistStyle.Shadow

    init(
        size: CGFloat = 44,
        shadow: BrutalistStyle.Shadow = .smallBlack
    ) {
        self.size = size
        self.shadow = shadow
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(Color.appBackgroundLight)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThin)
            )
            .background(
                // Shadow that counter-moves to stay fixed in absolute position
                Rectangle()
                    .fill(shadow.color)
                    .frame(width: size, height: size)
                    .offset(
                        x: shadow.offsetX - (configuration.isPressed ? shadow.pressedOffsetX : 0),
                        y: shadow.offsetY - (configuration.isPressed ? shadow.pressedOffsetY : 0)
                    )
            )
            .offset(
                x: configuration.isPressed ? shadow.pressedOffsetX : 0,
                y: configuration.isPressed ? shadow.pressedOffsetY : 0
            )
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Brutalist Drag Indicator
struct BrutalistDragIndicator: View {
    var body: some View {
        Rectangle()
            .fill(Color.brutalistBorder)
            .frame(width: 40, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }
}

// MARK: - Brutalist Toggle Style
struct BrutalistToggleStyle: ToggleStyle {
    let accentColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .fill(configuration.isOn ? accentColor : Color.appBackgroundLighter)
                .frame(width: 51, height: 31)
                .overlay(
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 27, height: 27)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.brutalistBorder, lineWidth: 2)
                )
                .onTapGesture {
                    withAnimation(.linear(duration: 0.1)) {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}

// MARK: - View Extensions for Easy Access
extension View {
    /// Apply brutalist card styling with border, background, and hard shadow
    func brutalistCard(
        borderColor: Color = .brutalistBorder,
        shadow: BrutalistStyle.Shadow = .cardBlack,
        backgroundColor: Color = .appBackgroundLight
    ) -> some View {
        modifier(BrutalistCard(borderColor: borderColor, shadowType: shadow, backgroundColor: backgroundColor))
    }

    /// Apply hard shadow using background rectangle technique
    func brutalistShadow(_ shadow: BrutalistStyle.Shadow) -> some View {
        modifier(BrutalistShadow(shadow: shadow))
    }
}
