//
//  SwipeCard.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

struct SwipeCard<Content: View>: View {
    let content: Content
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let onSwipeProgress: ((CGFloat) -> Void)?

    @State private var offset = CGSize.zero
    @State private var isDragging = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0

    // Computed shadow color based on swipe direction
    private var shadowColor: Color {
        if offset.width > 50 {
            return Color.starColor
        } else if offset.width < -50 {
            return Color.passColor
        } else {
            return BrutalistStyle.Shadow.cardPrimary.color
        }
    }

    init(
        @ViewBuilder content: () -> Content,
        onSwipeLeft: @escaping () -> Void,
        onSwipeRight: @escaping () -> Void,
        onSwipeProgress: ((CGFloat) -> Void)? = nil
    ) {
        self.content = content()
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeProgress = onSwipeProgress
    }
    
    var body: some View {
        ZStack {
            // Pass label (left)
            VStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(.close)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.passColor)

                    Text("PASS")
                        .font(.system(.title2))
                        .fontWeight(.black)
                        .foregroundColor(Color.passColor)

                    Text("NOT INTERESTED")
                        .font(.system(.caption))
                        .fontWeight(.heavy)
                        .foregroundColor(Color.passColor)
                }
                .scaleEffect(offset.width < -80 ? 1.1 : 1.0)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(offset.width < 0 ? min(Double(-offset.width) / 80, 1) : 0)
            .allowsHitTesting(false)
            
            // Star label (right)
            VStack {
                Spacer()

                VStack(spacing: 8) {
                    Image(.star)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color.starColor)

                    Text("STAR")
                        .font(.system(.title2))
                        .fontWeight(.black)
                        .foregroundColor(Color.starColor)

                    Text("SAVE FOR LATER")
                        .font(.system(.caption))
                        .fontWeight(.heavy)
                        .foregroundColor(Color.starColor)
                }
                .scaleEffect(offset.width > 80 ? 1.1 : 1.0)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .opacity(offset.width > 0 ? min(Double(offset.width) / 80, 1) : 0)
            .allowsHitTesting(false)
            
            // Card
            content
                .overlay(
                    // Swipe direction overlay
                    ZStack {
                        if offset.width < -50 {
                            Color.passColor.opacity(0.3)
                                .transition(.opacity)
                        } else if offset.width > 50 {
                            Color.starColor.opacity(0.3)
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: offset.width)
                    .allowsHitTesting(false)
                )
                .clipShape(Rectangle())
                .overlay(
                    Rectangle()
                        .strokeBorder(
                            offset.width > 50 ?
                            Color.starColor :
                                offset.width < -50 ?
                                Color.passColor :
                                Color.brutalistBorder,
                            lineWidth: BrutalistStyle.borderThick
                        )
                        .animation(.easeInOut(duration: 0.2), value: offset.width)
                )
                .background(
                    Rectangle()
                        .fill(shadowColor)
                        .offset(x: 8, y: 8)
                        .animation(.easeInOut(duration: 0.2), value: shadowColor)
                )
                .scaleEffect(scale)
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 1), value: scale)
                .offset(x: offset.width, y: offset.height * 0.3)
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 1), value: offset)
                .rotationEffect(.degrees(rotation), anchor: .bottom)
                .animation(.interactiveSpring(response: 0.25, dampingFraction: 1), value: rotation)
        }
        .onChange(of: offset) { _, newOffset in
            // Continuously update progress as the card moves (including during animations)
            let normalizedProgress = newOffset.width / 120
            onSwipeProgress?(normalizedProgress)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 12)
                .onChanged { gesture in
                    // Only treat mostly-horizontal drags as swipes; let vertical drags scroll Markdown
                    if abs(gesture.translation.width) > abs(gesture.translation.height) {
                        isDragging = true
                        offset = gesture.translation
                        rotation = Double(gesture.translation.width / 20)
                        scale = 1.0 - (abs(gesture.translation.width) / 1000 * 0.1)
                    }
                }
                .onEnded { gesture in
                    let horizontal = abs(gesture.translation.width) > abs(gesture.translation.height)
                    isDragging = false
                    guard horizontal else { resetCard(); return }
                    let threshold: CGFloat = 120
                    let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                    
                    if offset.width > threshold || velocity > 800 {
                        // Star swipe (right)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = CGSize(width: 500, height: -100)
                            rotation = 20
                            scale = 0.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeRight()
                        }
                    } else if offset.width < -threshold || velocity < -800 {
                        // Dismiss swipe (left)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = CGSize(width: -500, height: -100)
                            rotation = -20
                            scale = 0.8
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onSwipeLeft()
                        }
                    } else {
                        // Snap back with bounce
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                            resetCard()
                        }
                    }
                }
        )
    }
    
    private func resetCard() {
        offset = .zero
        rotation = 0
        scale = 1.0
        onSwipeProgress?(0)
    }
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()
        
        SwipeCard(
            content: {
                Rectangle()
                    .fill(Color.appBackgroundLight)
                    .frame(height: 400)
                    .overlay(
                        Text("SWIPE ME!")
                            .font(.system(.title))
                            .fontWeight(.black)
                            .foregroundColor(Color.textPrimary)
                    )
            },
            onSwipeLeft: {
                // Dismissed
            },
            onSwipeRight: {
                // Starred
            }
        )
        .padding()
    }
}
