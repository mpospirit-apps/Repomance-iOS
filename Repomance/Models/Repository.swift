//
//  Repository.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import Foundation

struct Repository: Identifiable, Sendable {
    let id: Int
    let name: String
    let owner: String
    let description: String?
    let stargazersCount: Int
    let language: String?
    let htmlUrl: String?
    let forkCount: Int
    let watcherCount: Int
    let topics: [String]
    let license: String?
    let repoUpdateDate: String?
    let category: String?
    
    var displayDescription: String {
        description ?? "No description available"
    }
    
    var ownerName: String {
        owner
    }
    
    // Initialize from APIRepository
    init(from apiRepo: APIRepository) {
        self.id = apiRepo.github_id
        self.name = apiRepo.name
        self.owner = apiRepo.owner
        self.description = apiRepo.description
        self.stargazersCount = apiRepo.stargazer_count
        self.forkCount = apiRepo.fork_count
        self.watcherCount = apiRepo.watcher_count
        self.language = apiRepo.languages.keys.max { apiRepo.languages[$0] ?? 0 < apiRepo.languages[$1] ?? 0 }
        self.htmlUrl = nil
        self.topics = apiRepo.topics
        self.license = apiRepo.license
        self.repoUpdateDate = apiRepo.repo_update_date
        self.category = apiRepo.category
    }

    // Initialize from EnrichedTrendingRepo (for trending section)
    init(from trending: EnrichedTrendingRepo) {
        self.id = trending.githubId  // CRITICAL: Use GitHub ID for interaction tracking
        self.name = trending.trending.name
        self.owner = trending.trending.author
        self.description = trending.trending.description
        self.stargazersCount = trending.trending.stars
        self.forkCount = trending.trending.forks
        self.watcherCount = 0  // Not available from trending API
        self.language = trending.trending.language
        self.htmlUrl = trending.trending.url
        self.topics = []  // Not available from trending API
        self.license = nil  // Not available from trending API
        self.repoUpdateDate = nil  // Not available from trending API
        self.category = nil  // Trending repos don't have categories
    }

}

extension Repository: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language
        case stargazersCount = "stargazers_count"
        case htmlUrl = "html_url"
        case forkCount = "fork_count"
        case watcherCount = "watcher_count"
        case topics, license
        case repoUpdateDate = "repo_update_date"
        case category
    }
}

struct LanguageInfo: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let percentage: Double
    let color: String
}

