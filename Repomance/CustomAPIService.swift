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
        let urlString = "\(baseURL)interactions/"
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
            "user": username,
            "repository": githubRepoId,
            "interaction": interactionName
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
}
