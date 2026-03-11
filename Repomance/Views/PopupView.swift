//
//  PopupView.swift
//  Repomance
//
//  Center overlay popup card for displaying active notifications with markdown content.
//

import SwiftUI

struct PopupView: View {
    let popup: APIPopup
    @EnvironmentObject var popupManager: PopupManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isVisible = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dimmed background
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture { } // Prevent tap-through to background

                // Card
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(popup.title)
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(Color.textPrimary)

                            Spacer()

                            Text(formatDate(popup.created_at))
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)

                    // Divider
                    Rectangle()
                        .fill(Color.brutalistBorder)
                        .frame(height: 3)

                    // Markdown content — 45% of screen height
                    MarkdownWebView(markdown: popup.content)
                        .frame(height: geometry.size.height * 0.65)

                    // Divider
                    Rectangle()
                        .fill(Color.brutalistBorder)
                        .frame(height: 3)

                    // Dismiss button
                    Button(action: dismiss) {
                        Text("GOT IT")
                            .font(.headline)
                            .fontWeight(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(BrutalistButtonStyle(backgroundColor: Color.appAccent))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(Color.appBackground)
                .overlay(
                    Rectangle()
                        .stroke(Color.brutalistBorder, lineWidth: 3)
                )
                .modifier(BrutalistShadow(shadow: BrutalistStyle.Shadow(offsetX: 8, offsetY: 8, color: Color.brutalistBorder)))
                .padding(.horizontal, 24)
                .scaleEffect(isVisible ? 1 : 0.85)
                .opacity(isVisible ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isVisible = true
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.15)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            popupManager.dismissCurrentPopup()
        }
    }

    private func formatDate(_ dateString: String) -> String {
        if dateString.range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression) != nil {
            return dateString
        }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd"
        return displayFormatter.string(from: date)
    }
}
