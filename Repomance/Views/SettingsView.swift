//
//  SettingsView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 8.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("rizzSoundEnabled") private var rizzSoundEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Settings")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            VStack(spacing: 0) {
                                HStack {
                                    Toggle("Haptic Feedback", isOn: $hapticFeedbackEnabled)
                                        .toggleStyle(BrutalistToggleStyle(accentColor: Color.appAccent))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.textPrimary)
                                        .onChange(of: hapticFeedbackEnabled) { _, newValue in
                                            if newValue {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                            }
                                        }
                                }
                                .padding(16)
                                .background(Color.appBackgroundLight)

                                Rectangle()
                                    .fill(Color.brutalistBorder)
                                    .frame(height: BrutalistStyle.borderThin)

                                HStack {
                                    Toggle("Rizz Mode", isOn: $rizzSoundEnabled)
                                        .toggleStyle(BrutalistToggleStyle(accentColor: Color.appAccent))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.textPrimary)
                                        .onChange(of: rizzSoundEnabled) { _, _ in
                                            if hapticFeedbackEnabled {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                            }
                                        }
                                }
                                .padding(16)
                                .background(Color.appBackgroundLight)
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                            )
                            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                        }

                        // Appearance Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Appearance")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            VStack(spacing: 0) {
                                ForEach(ThemeMode.allCases, id: \.self) { theme in
                                    Button(action: {
                                        if hapticFeedbackEnabled {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                        }
                                        themeManager.selectedTheme = theme.rawValue
                                    }) {
                                        HStack {
                                            // Theme icon
                                            Image(systemName: themeIcon(for: theme))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color.appAccent)

                                            Text(theme.rawValue)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.textPrimary)

                                            Spacer()

                                            // Checkmark for selected theme
                                            if themeManager.currentTheme == theme {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20, weight: .bold))
                                                    .foregroundColor(Color.appAccent)
                                            }
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.appBackgroundLight)
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    // Divider between options
                                    if theme != ThemeMode.allCases.last {
                                        Rectangle()
                                            .fill(Color.brutalistBorder)
                                            .frame(height: BrutalistStyle.borderThin)
                                    }
                                }
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                            )
                            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                        }

                        // GitHub Authentication Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("GitHub Authentication")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)
                            
                            VStack(spacing: 0) {
                                if let username = authManager.username {
                                    HStack {
                                        Text("Connected Account")
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textPrimary)
                                        Spacer()
                                        Text(username)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color.textSecondary)
                                    }
                                    .padding(16)
                                    .background(Color.appBackgroundLight)

                                    Rectangle()
                                        .fill(Color.brutalistBorder)
                                        .frame(height: BrutalistStyle.borderThin)
                                }

                                Button(action: {
                                    authManager.logout()
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(.logout)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        Text("LOGOUT")
                                            .fontWeight(.black)
                                            .textCase(.uppercase)
                                        Spacer()
                                    }
                                    .foregroundColor(.red)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.appBackgroundLight)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                            )
                            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 8) {
                        BrutalistDragIndicator()
                        Text("SETTINGS")
                            .font(.system(.headline))
                            .fontWeight(.black)
                            .textCase(.uppercase)
                            .foregroundColor(Color.appAccent)
                    }
                }
            }
            .toolbarBackground(Color.appBackgroundLight, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if hapticFeedbackEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func themeIcon(for theme: ThemeMode) -> String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}

#Preview {
    SettingsView()
}
