//
//  GitHubAuth.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 8.12.2025.
//

import Foundation
import Combine
import AuthenticationServices

class GitHubAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var username: String?
    @Published var githubUserId: Int?
    @Published var userId: Int? // Database user ID
    @Published var userApiToken: String? // User-specific API token for backend

    // OAuth App credentials - configured via environment variables
    private let clientId = Config.githubClientId
    private let redirectURI = Config.redirectUri
    // Note: client secret is now only on backend for security

    // OAuth URLs
    private let authURL = Config.githubAuthUrl
    private let tokenURL = Config.githubTokenUrl
    
    func startOAuthFlow() {
        // Construct authorization URL
        var components = URLComponents(string: authURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "public_repo")
        ]

        guard let url = components.url else {
            return
        }

        // DEBUG: Print OAuth configuration

        // Use ASWebAuthenticationSession for proper OAuth handling
        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: "repomance"
        ) { [weak self] callbackURL, error in
            if let error = error {
                return
            }

            guard let callbackURL = callbackURL else {
                return
            }

            self?.handleCallback(url: callbackURL)
        }

        session.presentationContextProvider = AuthContextProvider.shared
        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }
    
    func handleCallback(url: URL) {
        // Extract code from callback URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return
        }
        
        // Exchange code for access token
        exchangeCodeForToken(code: code)
    }
    
    private func exchangeCodeForToken(code: String) {
        // Exchange code via backend (keeps client_secret secure on server)
        CustomAPIService.shared.exchangeGitHubCode(code: code) { [weak self] token, error in
            guard let self = self else { return }

            if let error = error {
                return
            }

            guard let token = token else {
                return
            }

            DispatchQueue.main.async {
                self.accessToken = token
                self.saveToken(token)
                // Exchange GitHub token for user API token
                self.exchangeGitHubTokenForAPIToken(githubToken: token)
            }
        }
    }
    
    private func exchangeGitHubTokenForAPIToken(githubToken: String) {
        // Exchange GitHub token for user-specific API token via backend
        let urlString = "\(Config.customApiBaseUrl)auth/generate-token/"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "github_token": githubToken,
            "device_name": "iOS App"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let apiToken = json["api_token"] as? String,
                  let username = json["username"] as? String,
                  let userId = json["user_id"] as? Int else {
                return
            }

            DispatchQueue.main.async {
                // Store the user API token securely in Keychain
                KeychainHelper.shared.saveAPIToken(apiToken)

                self.userApiToken = apiToken
                self.username = username
                self.userId = userId
                self.isAuthenticated = true

                // Still fetch GitHub user info for githubUserId
                self.fetchUserInfo()
            }
        }.resume()
    }

    private func fetchUserInfo() {
        guard let token = accessToken else { return }

        var request = URLRequest(url: URL(string: "\(Config.githubApiBaseUrl)/user")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let userId = json["id"] as? Int else {
                return
            }

            DispatchQueue.main.async {
                self?.githubUserId = userId
            }
        }.resume()
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "github_access_token")
    }
    
    func loadToken() {
        // Try to load the user API token from Keychain first
        if let apiToken = KeychainHelper.shared.getAPIToken() {
            userApiToken = apiToken
            isAuthenticated = true

            // Also try to load GitHub token if available
            if let githubToken = UserDefaults.standard.string(forKey: "github_access_token") {
                accessToken = githubToken
                fetchUserInfo()
            }
        } else if let githubToken = UserDefaults.standard.string(forKey: "github_access_token") {
            // Fallback: if we have a GitHub token but no API token, exchange it
            accessToken = githubToken
            exchangeGitHubTokenForAPIToken(githubToken: githubToken)
        }
    }
    
    func logout() {
        accessToken = nil
        username = nil
        githubUserId = nil
        userId = nil
        userApiToken = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "github_access_token")
        KeychainHelper.shared.deleteAPIToken()
    }
    
    func checkRepositoryExists(owner: String, repo: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(Config.githubApiBaseUrl)/repos/\(owner)/\(repo)")!
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0
            let exists = statusCode == 200

            DispatchQueue.main.async {
                completion(exists)
            }
        }.resume()
    }

    func starRepository(owner: String, repo: String, completion: @escaping (Bool) -> Void) {
        starRepositoryWithRetry(owner: owner, repo: repo, retryCount: 0, completion: completion)
    }

    private func starRepositoryWithRetry(owner: String, repo: String, retryCount: Int, completion: @escaping (Bool) -> Void) {
        guard let token = accessToken else {
            completion(false)
            return
        }

        // Validate token before attempting to star
        validateToken { [weak self] isValid in
            if !isValid {
                completion(false)
                return
            }

            self?.performStarOperation(owner: owner, repo: repo, token: token, retryCount: retryCount, completion: completion)
        }
    }

    private func validateToken(completion: @escaping (Bool) -> Void) {
        guard let token = accessToken else {
            completion(false)
            return
        }

        var request = URLRequest(url: URL(string: "\(Config.githubApiBaseUrl)/user")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let isValid = httpResponse?.statusCode == 200

            DispatchQueue.main.async {
                completion(isValid)
            }
        }.resume()
    }

    private func performStarOperation(owner: String, repo: String, token: String, retryCount: Int, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "\(Config.githubApiBaseUrl)/user/starred/\(owner)/\(repo)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("0", forHTTPHeaderField: "Content-Length")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0

            // Enhanced error handling with specific messages
            let success: Bool
            switch statusCode {
            case 204:
                success = true
            case 404, 401, 403, 422:
                success = false
            default:
                success = false
            }

            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
    
    // Helper class to provide presentation context for ASWebAuthenticationSession
    class AuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
        static let shared = AuthContextProvider()

        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            // Get the active window scene
            let windowScene = UIApplication.shared.connectedScenes
                .first { $0.activationState == .foregroundActive } as? UIWindowScene

            // Return the key window from the active scene
            if let window = windowScene?.keyWindow {
                return window
            }

            // Fallback: try any window from any scene
            for scene in UIApplication.shared.connectedScenes {
                if let windowScene = scene as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return window
                }
            }

            // Last resort: create a new window
            return UIWindow(frame: UIScreen.main.bounds)
        }
    }
}
