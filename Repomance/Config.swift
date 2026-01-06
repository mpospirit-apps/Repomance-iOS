//
//  Config.swift
//  Repomance
//
//  Configuration management for sensitive values
//

import Foundation

struct Config {
    // GitHub OAuth Configuration
    // Note: Client ID is not sensitive (it's visible in OAuth URLs anyway)
    static let githubClientId: String = {
        if let envValue = ProcessInfo.processInfo.environment["GITHUB_OAUTH_CLIENT_ID"] {
            return envValue
        }
        // Read from Info.plist (set via xcconfig file)
        if let plistValue = Bundle.main.infoDictionary?["GITHUB_OAUTH_CLIENT_ID"] as? String {
            return plistValue
        }
        // No fallback - must be configured via environment or xcconfig
        return ""
    }()

    // ⚠️ CLIENT SECRET REMOVED - Now handled securely on backend
    // OAuth token exchange now goes through: iOS → Backend → GitHub
    // This keeps the secret on the server where it belongs

    // Custom API Configuration
    static let customApiKey: String = {
        // Check environment variables first (Xcode scheme)
        if let envValue = ProcessInfo.processInfo.environment["REPOMANCE_API_KEY"],
           !envValue.isEmpty,
           envValue != "$(REPOMANCE_API_KEY)" {
            return envValue
        }

        // Check Info.plist (from INFOPLIST_KEY_REPOMANCE_API_KEY)
        if let plistValue = Bundle.main.infoDictionary?["REPOMANCE_API_KEY"] as? String,
           !plistValue.isEmpty,
           plistValue != "$(REPOMANCE_API_KEY)" {
            return plistValue
        }

        // Check for the key with INFOPLIST_KEY prefix (in case it wasn't stripped)
        if let plistValue = Bundle.main.infoDictionary?["INFOPLIST_KEY_REPOMANCE_API_KEY"] as? String,
           !plistValue.isEmpty,
           plistValue != "$(REPOMANCE_API_KEY)" {
            return plistValue
        }

        // No fallback - API key must be configured via environment or xcconfig
        return ""
    }()

    static var isConfiguredProperly: Bool {
        return !customApiKey.isEmpty && customApiKey != "$(REPOMANCE_API_KEY)"
    }

    // API URLs - these can remain hardcoded as they're not sensitive
    static let githubApiBaseUrl = "https://api.github.com"
    static let githubAuthUrl = "https://github.com/login/oauth/authorize"
    static let githubTokenUrl = "https://github.com/login/oauth/access_token"
    static let customApiBaseUrl = "https://repomance.com/api/"
    static let redirectUri = "repomance://oauth-callback"
}