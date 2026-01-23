//
//  SettingsView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 8.12.2025.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: GitHubAuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("rizzSoundEnabled") private var rizzSoundEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var showDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var deleteErrorMessage: String?

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

                                Rectangle()
                                    .fill(Color.brutalistBorder)
                                    .frame(height: BrutalistStyle.borderThin)

                                Button(action: {
                                    showDeleteConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16, weight: .bold))
                                        Text("DELETE ACCOUNT")
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
                                .disabled(isDeletingAccount)
                                .opacity(isDeletingAccount ? 0.5 : 1.0)
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
                            )
                            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                        }

                        Divider()
                            .background(Color.textSecondary.opacity(0.3))
                            .padding(.vertical, 8)

                        // Links Section
                        HStack(spacing: 8) {
                            Button(action: {
                                openURL(URL(string: "https://repomance.com/privacy")!)
                            }) {
                                Text("Privacy Policy")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }

                            Text("|")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary.opacity(0.5))

                            Button(action: {
                                openURL(URL(string: "https://repomance.com/license")!)
                            }) {
                                Text("License")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }

                            Text("|")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.textSecondary.opacity(0.5))

                            Button(action: {
                                openURL(URL(string: "https://repomance.com/support")!)
                            }) {
                                Text("Support")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                        // About Section
                        VStack(alignment: .center, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("Made with")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textPrimary)
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(Color.appAccent)
                                Text("by")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.textPrimary)
                            }
                            Button(action: {
                                openURL(URL(string: "https://www.cagrigokpunar.com")!)
                            }) {
                                Text("Çağrı \"mpospirit\" Gökpunar")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                        .frame(maxWidth: .infinity)

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
            .overlay {
                if showDeleteConfirmation {
                    BrutalistDeleteAccountAlert(
                        isPresented: $showDeleteConfirmation,
                        onDelete: deleteAccount
                    )
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    private func deleteAccount() {
        guard let userId = authManager.userId else {
            deleteErrorMessage = "User ID not found"
            return
        }

        isDeletingAccount = true
        deleteErrorMessage = nil

        if hapticFeedbackEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }

        CustomAPIService.shared.deleteAccount(userId: userId) { success, error in
            isDeletingAccount = false

            if success {
                if hapticFeedbackEnabled {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }

                // Logout clears Keychain, UserDefaults, and resets auth state
                authManager.logout()
                dismiss()
            } else {
                deleteErrorMessage = error ?? "Failed to delete account"

                if hapticFeedbackEnabled {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                }
            }
        }
    }

    private func themeIcon(for theme: ThemeMode) -> String {
        switch theme {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    private func openURL(_ url: URL) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                var topController = window.rootViewController
                while let presented = topController?.presentedViewController {
                    topController = presented
                }

                let safariVC = SFSafariViewController(url: url)
                topController?.present(safariVC, animated: true)
            }
        }
    }
}

// MARK: - Brutalist Delete Account Alert

struct BrutalistDeleteAccountAlert: View {
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background dimming
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            // Alert card
            VStack(spacing: 0) {
                // Title
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)

                    Text("DELETE ACCOUNT?")
                        .font(.system(size: 24))
                        .fontWeight(.black)
                        .textCase(.uppercase)
                        .foregroundColor(Color.textPrimary)
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)

                // Message with bullet points
                VStack(alignment: .leading, spacing: 12) {
                    BulletPoint(text: "This action is PERMANENT and cannot be undone")
                    BulletPoint(text: "All your interaction data will be deleted")
                    BulletPoint(text: "Your GitHub stars will remain unchanged")
                    BulletPoint(text: "You can create a new account by signing in again")
                }
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Buttons
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.brutalistBorder)
                        .frame(height: BrutalistStyle.borderThick)
                        .padding(.top, 24)

                    Button(action: {
                        isPresented = false
                        onDelete()
                    }) {
                        Text("DELETE ACCOUNT")
                            .fontWeight(.black)
                            .textCase(.uppercase)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.appBackgroundLight)
                    }

                    Rectangle()
                        .fill(Color.brutalistBorder)
                        .frame(height: BrutalistStyle.borderThick)

                    Button(action: {
                        isPresented = false
                    }) {
                        Text("CANCEL")
                            .fontWeight(.black)
                            .textCase(.uppercase)
                            .foregroundColor(Color.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.appBackgroundLight)
                    }
                }
            }
            .frame(width: 340)
            .background(Color.appBackgroundLight)
            .overlay(
                Rectangle()
                    .stroke(Color.brutalistBorder, lineWidth: BrutalistStyle.borderThick)
            )
            .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

// MARK: - Bullet Point Component

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 20))
                .fontWeight(.black)
                .foregroundColor(Color.textPrimary)

            Text(text)
                .font(.system(size: 14))
                .fontWeight(.bold)
                .foregroundColor(Color.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SettingsView()
}
