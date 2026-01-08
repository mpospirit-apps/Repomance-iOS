//
//  CustomAPIService.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 13.12.2025.
//

import Foundation
import Combine

struct APIRepository: Codable, Identifiable, Sendable {
    let id: Int
    let github_id: Int
    let owner: String
    let name: String
    let category: String
    let description: String
    let stargazer_count: Int
    let watcher_count: Int
    let fork_count: Int
    let languages: [String: Int]
    let license: String?
    let topics: [String]
    let repo_creation_date: String
    let repo_update_date: String
}

struct APIRepositoryReadme: Codable, Sendable {
    let id: Int
    let github_id: Int
    let readme_content: String
}

struct APIGithubUser: Codable, Sendable {
    let id: Int?
    let github_username: String
    let github_id: Int
    let last_login: String
    let created_at: String?
}

struct APIUserRepositoryInteraction: Codable {
    let id: Int?
    let user: String
    let repository: Int
    let interaction: String
    let interacted_at: String?
}

struct UninteractedReposResponse: Codable, Sendable {
    let username: String
    let batch_size: Int
    let filters: [String: AnyCodable]?
    let count: Int
    let repositories: [APIRepository]
}

struct CategoriesResponse: Codable, Sendable {
    let count: Int
    let categories: [String]
}

struct BatchGenerationResponse: Codable {
    let id: Int
    let user: Int
    let generated_at: String
}

struct DailyBatchCountResponse: Codable, Sendable {
    let date: String
    let batch_count: Int
}

struct UserInteractionsResponse: Codable, Sendable {
    let id: Int
    let user: String
    let repository: Int
    let interaction: String
    let interacted_at: String
}

// MARK: - Trending Uninteracted Response Models

struct TrendingRepoAPIResponse: Codable, Sendable {
    let github_id: Int
    let owner: String
    let name: String
    let description: String?
    let language: String?
    let stars: Int
    let forks: Int
    let url: String?
}

struct TrendingFiltersResponse: Codable, Sendable {
    let language: String?
    let period: String
}

struct UninteractedTrendingReposResponse: Codable, Sendable {
    let username: String
    let batch_size: Int
    let filters: TrendingFiltersResponse
    let count: Int
    let repositories: [TrendingRepoAPIResponse]
}

struct UserStats: Sendable {
    let totalInteractions: Int
    let starsCount: Int
    let skipsCount: Int
    let dailyBatchCount: Int
}

struct AnyCodable: Codable, @unchecked Sendable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([String].self) {
            value = arrayValue
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let arrayValue = value as? [String] {
            try container.encode(arrayValue)
        }
    }
}

class CustomAPIService: ObservableObject {
    static let shared = CustomAPIService()

    private let baseURL = Config.customApiBaseUrl

    // Get the user-specific API token from Keychain
    private var apiToken: String? {
        let token = KeychainHelper.shared.getAPIToken()
        if token == nil {
        } else {
        }
        return token
    }

    // Helper function for decoding
    private func decode<T: Decodable>(type: T.Type, from data: Data) throws -> T {
        return try JSONDecoder().decode(type, from: data)
    }
    
    func fetchRepository(id: Int, completion: @escaping @Sendable (APIRepository?) -> Void) {
        let urlString = "\(baseURL)repos/\(id)/"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode == 403 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let repository = try self.decode(type: APIRepository.self, from: data)
                    await MainActor.run {
                        completion(repository)
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }
    
    func fetchReadme(id: Int, completion: @escaping @Sendable (String?) -> Void) {
        let urlString = "\(baseURL)repos/\(id)/readme/"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode == 401 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode == 403 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let readme = try self.decode(type: APIRepositoryReadme.self, from: data)

                    // Remove newlines from base64 string before decoding
                    let cleanBase64 = readme.readme_content.replacingOccurrences(of: "\n", with: "")

                    // Decode base64 content
                    if let decodedData = Data(base64Encoded: cleanBase64),
                       let decodedString = String(data: decodedData, encoding: .utf8) {
                        await MainActor.run {
                            completion(decodedString)
                        }
                    } else {
                        await MainActor.run {
                            completion(nil)
                        }
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }
    
    func createOrUpdateUser(githubUsername: String, githubId: Int, completion: @escaping @Sendable (Bool, Int?) -> Void) {
        let urlString = "\(baseURL)users/"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let isoFormatter = ISO8601DateFormatter()
        let currentDate = isoFormatter.string(from: Date())

        let body: [String: Any] = [
            "github_username": githubUsername,
            "github_id": githubId,
            "last_login": currentDate,
            "created_at": currentDate
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    // Parse response to get user ID
                    Task.detached {
                        if let data = data,
                           let user = try? self.decode(type: APIGithubUser.self, from: data) {
                            await MainActor.run {
                                completion(true, user.id)
                            }
                        } else {
                            await MainActor.run {
                                completion(true, nil)
                            }
                        }
                    }
                } else if httpResponse.statusCode == 400 {
                    // User might already exist, try to update
                    self.updateUserLogin(githubUsername: githubUsername, completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
            }
        }.resume()
    }
    
    private func updateUserLogin(githubUsername: String, completion: @escaping @Sendable (Bool, Int?) -> Void) {
        // First get the user ID
        let urlString = "\(baseURL)users/"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            Task.detached {
                guard let data = data else {
                    await MainActor.run {
                        completion(false, nil)
                    }
                    return
                }

                do {
                    let users = try self.decode(type: [APIGithubUser].self, from: data)
                    if let user = users.first(where: { $0.github_username == githubUsername }) {
                        await MainActor.run {
                            self.patchUserLogin(userId: user.id ?? 0, completion: completion)
                        }
                    } else {
                        await MainActor.run {
                            completion(false, nil)
                        }
                    }
                } catch {
                    await MainActor.run {
                        completion(false, nil)
                    }
                }
            }
        }.resume()
    }
    
    private func patchUserLogin(userId: Int, completion: @escaping @Sendable (Bool, Int?) -> Void) {
        let urlString = "\(baseURL)users/\(userId)/"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let isoFormatter = ISO8601DateFormatter()
        let currentDate = isoFormatter.string(from: Date())

        let body: [String: Any] = [
            "last_login": currentDate
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                let success = httpResponse.statusCode == 200
                DispatchQueue.main.async {
                    completion(success, success ? userId : nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }.resume()
    }
    
    func recordInteraction(username: String, githubRepoId: Int, interactionName: String, completion: @escaping @Sendable (Bool) -> Void) {
        print("💾 [CustomAPIService] Recording interaction - username: \(username), repoId: \(githubRepoId), interaction: \(interactionName)")

        let urlString = "\(baseURL)interactions/"
        print("🌐 [CustomAPIService] Request URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("❌ [CustomAPIService] Invalid URL for recordInteraction: \(urlString)")
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 [CustomAPIService] Using API token for authentication")
        } else {
            print("⚠️ [CustomAPIService] No API token available for recordInteraction")
        }

        let body: [String: Any] = [
            "user": username,
            "repository": githubRepoId,
            "interaction": interactionName
        ]

        print("📦 [CustomAPIService] Request body: \(body)")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ [CustomAPIService] Network error recording interaction: \(error.localizedDescription)")
                print("❌ [CustomAPIService] Failed to record \(interactionName) for repo \(githubRepoId)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] recordInteraction API response status: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 201 {
                    print("✅ [CustomAPIService] Successfully recorded \(interactionName) for repo \(githubRepoId)")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("❌ [CustomAPIService] Failed to record interaction - status \(httpResponse.statusCode)")

                    // Log response body for debugging
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 [CustomAPIService] Response body: \(responseBody)")
                    }

                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                print("❌ [CustomAPIService] No HTTP response received for recordInteraction")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    func saveTrendingRepo(
        githubId: Int,
        owner: String,
        name: String,
        description: String?,
        stars: Int,
        forks: Int,
        language: String?,
        url: String?,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        print("💾 [CustomAPIService] Saving trending repo to database - \(owner)/\(name) (ID: \(githubId))")

        let urlString = "\(baseURL)repos/trending/save/"
        print("🌐 [CustomAPIService] Request URL: \(urlString)")

        guard let apiURL = URL(string: urlString) else {
            print("❌ [CustomAPIService] Invalid URL for saveTrendingRepo: \(urlString)")
            completion(false)
            return
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 [CustomAPIService] Using API token for authentication")
        } else {
            print("⚠️ [CustomAPIService] No API token available for saveTrendingRepo")
        }

        let body: [String: Any] = [
            "github_id": githubId,
            "owner": owner,
            "name": name,
            "description": description ?? "",
            "stargazer_count": stars,
            "fork_count": forks,
            "language": language ?? "",
            "url": url ?? ""
        ]

        print("📦 [CustomAPIService] Request body: \(body)")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ [CustomAPIService] Network error saving trending repo: \(error.localizedDescription)")
                print("❌ [CustomAPIService] Failed to save \(owner)/\(name)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] saveTrendingRepo API response status: \(httpResponse.statusCode)")

                if httpResponse.statusCode == 201 {
                    print("✅ [CustomAPIService] Successfully saved trending repo \(owner)/\(name) (ID: \(githubId))")
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    print("❌ [CustomAPIService] Failed to save trending repo - status \(httpResponse.statusCode)")

                    // Log response body for debugging
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 [CustomAPIService] Response body: \(responseBody)")
                    }

                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                print("❌ [CustomAPIService] No HTTP response received for saveTrendingRepo")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    func fetchUninteractedRepos(username: String, batchSize: Int = 10, categories: [String]? = nil, minStarCount: Int? = nil, maxStarCount: Int? = nil, languages: [String]? = nil, completion: @escaping @Sendable (UninteractedReposResponse?) -> Void) {
        var components = URLComponents(string: "\(baseURL)repos/uninteracted/")!
        var queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "batch_size", value: String(batchSize))
        ]
        
        if let categories = categories, !categories.isEmpty {
            for category in categories {
                queryItems.append(URLQueryItem(name: "category", value: category))
            }
        }
        
        if let minStarCount = minStarCount {
            queryItems.append(URLQueryItem(name: "min_star_count", value: String(minStarCount)))
        }
        
        if let maxStarCount = maxStarCount {
            queryItems.append(URLQueryItem(name: "max_star_count", value: String(maxStarCount)))
        }
        
        if let languages = languages, !languages.isEmpty {
            let languagesString = languages.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "languages", value: languagesString))
        }
        
        components.queryItems = queryItems

        guard let url = components.url else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    print("🔐 [CustomAPIService] 401 Unauthorized on curated repos - token is invalid, clearing keychain")
                    KeychainHelper.shared.deleteAPIToken()
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("TokenInvalidated"), object: nil)
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let response = try self.decode(type: UninteractedReposResponse.self, from: data)
                    await MainActor.run {
                        completion(response)
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    // MARK: - Trending Uninteracted Repos

    func fetchUninteractedTrendingRepos(
        username: String,
        batchSize: Int = 30,
        language: String? = nil,
        period: TrendingPeriod = .weekly,
        completion: @escaping @Sendable (UninteractedTrendingReposResponse?) -> Void
    ) {
        print("🌐 [CustomAPIService] Fetching uninteracted trending repos - username: \(username), language: \(language ?? "nil"), period: \(period.rawValue)")

        var components = URLComponents(string: "\(baseURL)repos/trending/uninteracted/")!
        var queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "batch_size", value: String(batchSize)),
            URLQueryItem(name: "period", value: period.rawValue)
        ]

        if let language = language {
            queryItems.append(URLQueryItem(name: "language", value: language))
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            print("❌ [CustomAPIService] Invalid URL for trending uninteracted repos")
            completion(nil)
            return
        }

        print("🌐 [CustomAPIService] Request URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 [CustomAPIService] Using API token for authentication (length: \(token.count))")
        } else {
            print("⚠️ [CustomAPIService] No API token available for trending uninteracted repos")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [CustomAPIService] Network error fetching trending: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] Trending API response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 401 {
                    print("🔐 [CustomAPIService] 401 Unauthorized - token is invalid, clearing keychain")
                    // Clear invalid token from keychain
                    KeychainHelper.shared.deleteAPIToken()
                    // Post notification to trigger logout/re-auth
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("TokenInvalidated"), object: nil)
                        completion(nil)
                    }
                    return
                } else if httpResponse.statusCode != 200 {
                    print("⚠️ [CustomAPIService] Non-200 status code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                print("❌ [CustomAPIService] No data received from trending API")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            print("📦 [CustomAPIService] Received \(data.count) bytes from trending API")

            Task.detached {
                do {
                    let response = try self.decode(type: UninteractedTrendingReposResponse.self, from: data)
                    print("✅ [CustomAPIService] Successfully decoded \(response.count) trending repos")
                    await MainActor.run {
                        completion(response)
                    }
                } catch {
                    print("❌ [CustomAPIService] Failed to decode trending response: \(error)")
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    func fetchCategories(completion: @escaping @Sendable ([String]) -> Void) {
        let urlString = "\(baseURL)repos/categories/"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion([])
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            Task.detached {
                do {
                    let response = try self.decode(type: CategoriesResponse.self, from: data)
                    await MainActor.run {
                        completion(response.categories)
                    }
                } catch {
                    await MainActor.run {
                        completion([])
                    }
                }
            }
        }.resume()
    }
    
    func logBatchGeneration(userId: Int, completion: @escaping @Sendable (Bool) -> Void) {
        let urlString = "\(baseURL)batch/log/"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let body: [String: Any] = [
            "user_id": userId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            }
        }.resume()
    }
    
    func fetchDailyBatchCount(completion: @escaping @Sendable (Int?) -> Void) {
        let urlString = "\(baseURL)batch/daily-count/"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let response = try self.decode(type: DailyBatchCountResponse.self, from: data)
                    await MainActor.run {
                        completion(response.batch_count)
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    func exchangeGitHubCode(
        code: String,
        completion: @escaping @Sendable (String?, String?) -> Void
    ) {
        let urlString = "\(baseURL)auth/github/exchange/"

        guard let url = URL(string: urlString) else {
            completion(nil, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: Any] = ["code": code]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error.localizedDescription)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let accessToken = json["access_token"] as? String {
                        DispatchQueue.main.async {
                            completion(accessToken, nil)
                        }
                        return
                    }
                }

                // Parse error message
                var errorMsg = "OAuth exchange failed (HTTP \(httpResponse.statusCode))"
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = json["error"] as? String {
                    errorMsg = error
                    if let details = json["details"] as? String {
                        errorMsg += ": \(details)"
                    }
                }
                DispatchQueue.main.async {
                    completion(nil, errorMsg)
                }
            }
        }.resume()
    }

    func fetchUserStats(userId: Int, completion: @escaping @Sendable (UserStats?) -> Void) {
        // Fetch user interactions
        let interactionsURL = "\(baseURL)users/\(userId)/interactions/"
        guard let url = URL(string: interactionsURL) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let interactions = try self.decode(type: [UserInteractionsResponse].self, from: data)

                    // Calculate statistics
                    let totalInteractions = interactions.count
                    let starsCount = interactions.filter { $0.interaction == "Star" }.count
                    let skipsCount = interactions.filter { $0.interaction == "Pass" }.count

                    // Fetch daily batch count
                    await MainActor.run {
                        self.fetchDailyBatchCount { dailyCount in
                            let stats = UserStats(
                                totalInteractions: totalInteractions,
                                starsCount: starsCount,
                                skipsCount: skipsCount,
                                dailyBatchCount: dailyCount ?? 0
                            )
                            completion(stats)
                        }
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    // MARK: - Trending Repos Methods

    func fetchTrendingRepositories(
        language: String? = nil,
        since: TrendingPeriod = .daily,
        token: String,
        completion: @escaping @Sendable ([GitHubTrendingRepository]?) -> Void
    ) {
        print("🌐 [CustomAPIService] Fetching trending repos - language: \(language ?? "nil"), since: \(since.rawValue)")

        // Calculate date for the search query
        let calendar = Calendar.current
        let daysAgo = since.daysAgo
        guard let fromDate = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else {
            print("❌ [CustomAPIService] Failed to calculate date")
            completion(nil)
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: fromDate)

        // Build search query: created:>DATE [language:LANG]
        var query = "created:>\(dateString)"
        if let language = language {
            query += " language:\(language)"
        }

        print("🔍 [CustomAPIService] Search query: \(query)")

        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "per_page", value: "30")
        ]

        guard let url = components.url else {
            print("❌ [CustomAPIService] Invalid URL for trending repos")
            completion(nil)
            return
        }

        print("🌐 [CustomAPIService] Request URL: \(url.absoluteString)")

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [CustomAPIService] Network error fetching trending: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] GitHub Search API response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("⚠️ [CustomAPIService] Non-200 status code: \(httpResponse.statusCode)")
                }
            }

            guard let data = data else {
                print("❌ [CustomAPIService] No data received from GitHub Search API")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            print("📦 [CustomAPIService] Received \(data.count) bytes from GitHub Search API")

            Task.detached {
                do {
                    let searchResponse = try self.decode(type: GitHubSearchResponse.self, from: data)
                    print("✅ [CustomAPIService] Successfully decoded \(searchResponse.items.count) search results")

                    // Map search results to GitHubTrendingRepository
                    let trendingRepos = searchResponse.items.map { item in
                        GitHubTrendingRepository(
                            author: item.owner.login,
                            name: item.name,
                            url: item.html_url,
                            description: item.description,
                            language: item.language,
                            languageColor: nil,  // Not available from search API
                            stars: item.stargazers_count,
                            forks: item.forks_count,
                            currentPeriodStars: 0,  // Not available from search API
                            builtBy: nil,  // Not available from search API
                            githubId: item.id  // GitHub ID from search API
                        )
                    }

                    print("✅ [CustomAPIService] Mapped to \(trendingRepos.count) trending repos")
                    await MainActor.run {
                        completion(trendingRepos)
                    }
                } catch {
                    print("❌ [CustomAPIService] Failed to decode search results: \(error)")
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    func fetchGitHubRepoDetails(
        owner: String,
        repo: String,
        token: String,
        completion: @escaping @Sendable (Int?) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)"
        print("🔍 [CustomAPIService] Fetching GitHub repo details for \(owner)/\(repo)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [CustomAPIService] Invalid URL for repo details: \(urlString)")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [CustomAPIService] Network error fetching repo details for \(owner)/\(repo): \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] GitHub API response for \(owner)/\(repo): \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("⚠️ [CustomAPIService] Non-200 status code for \(owner)/\(repo)")
                }
            }
            
            guard let data = data else {
                print("❌ [CustomAPIService] No data received for \(owner)/\(repo)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    let repoDetails = try self.decode(type: GitHubRepoDetails.self, from: data)
                    print("✅ [CustomAPIService] Got GitHub ID \(repoDetails.id) for \(owner)/\(repo)")
                    await MainActor.run {
                        completion(repoDetails.id)
                    }
                } catch {
                    print("❌ [CustomAPIService] Failed to decode repo details for \(owner)/\(repo): \(error)")
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }

    func fetchUserInteractions(
        username: String,
        completion: @escaping @Sendable ([Int]) -> Void
    ) {
        // Fetch all interactions for the user to filter trending repos
        let urlString = "\(baseURL)users/interactions/?username=\(username)"
        print("🔍 [CustomAPIService] Fetching user interactions for: \(username)")
        print("🌐 [CustomAPIService] Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ [CustomAPIService] Invalid URL for user interactions")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔐 [CustomAPIService] Using API token for authentication")
        } else {
            print("⚠️ [CustomAPIService] No API token available")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [CustomAPIService] Network error fetching interactions: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [CustomAPIService] Interactions API response status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("⚠️ [CustomAPIService] Non-200 status code for interactions")
                }
            }
            
            guard let data = data else {
                print("❌ [CustomAPIService] No data received from interactions API")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            print("📦 [CustomAPIService] Received \(data.count) bytes from interactions API")
            
            Task.detached {
                do {
                    let interactions = try self.decode(type: [UserInteractionsResponse].self, from: data)
                    let githubIds = interactions.map { $0.repository }
                    print("✅ [CustomAPIService] Successfully decoded \(interactions.count) interactions, \(githubIds.count) unique repo IDs")
                    await MainActor.run {
                        completion(githubIds)
                    }
                } catch {
                    print("❌ [CustomAPIService] Failed to decode interactions: \(error)")
                    await MainActor.run {
                        completion([])
                    }
                }
            }
        }.resume()
    }

    func fetchGitHubReadme(
        owner: String,
        repo: String,
        token: String,
        completion: @escaping @Sendable (String?) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/readme"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    // README not found
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            Task.detached {
                do {
                    // Parse the response to get base64 content
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let content = json["content"] as? String,
                       let encoding = json["encoding"] as? String,
                       encoding == "base64" {

                        // Remove newlines from base64 string before decoding
                        let cleanBase64 = content.replacingOccurrences(of: "\n", with: "")

                        // Decode base64 content
                        if let decodedData = Data(base64Encoded: cleanBase64),
                           let decodedString = String(data: decodedData, encoding: .utf8) {
                            await MainActor.run {
                                completion(decodedString)
                            }
                        } else {
                            await MainActor.run {
                                completion(nil)
                            }
                        }
                    } else {
                        await MainActor.run {
                            completion(nil)
                        }
                    }
                } catch {
                    await MainActor.run {
                        completion(nil)
                    }
                }
            }
        }.resume()
    }
}

// MARK: - GitHub Search API Models

struct GitHubSearchResponse: Codable, Sendable {
    let items: [GitHubSearchRepository]
}

struct GitHubSearchRepository: Codable, Sendable {
    let id: Int
    let name: String
    let owner: GitHubSearchOwner
    let html_url: String
    let description: String?
    let language: String?
    let stargazers_count: Int
    let forks_count: Int
}

struct GitHubSearchOwner: Codable, Sendable {
    let login: String
}

// MARK: - Trending Period Enum

enum TrendingPeriod: String, Codable, Sendable {
    case daily
    case weekly
    case monthly

    var daysAgo: Int {
        switch self {
        case .daily: return 1
        case .weekly: return 7
        case .monthly: return 30
        }
    }
}
