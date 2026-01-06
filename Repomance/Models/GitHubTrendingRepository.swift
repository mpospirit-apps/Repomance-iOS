//
//  GitHubTrendingRepository.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import Foundation

// Model for GitHub trending API response from ghapi.huchen.dev
struct GitHubTrendingRepository: Codable, Identifiable, Sendable {
    let author: String
    let name: String
    let url: String
    let description: String?
    let language: String?
    let languageColor: String?
    let stars: Int
    let forks: Int
    let currentPeriodStars: Int
    let builtBy: [TrendingContributor]?

    var id: String {
        "\(author)/\(name)"
    }
}

struct TrendingContributor: Codable, Sendable {
    let username: String
    let avatar: String
    let url: String
}

// Enriched trending repo with GitHub ID for interaction tracking
struct EnrichedTrendingRepo: Codable, Identifiable, Sendable {
    let trending: GitHubTrendingRepository
    let githubId: Int  // GitHub's numeric repo ID from api.github.com
    let fetchedAt: Date

    var id: String {
        trending.id
    }
}

// Model for GitHub API repo details response (to get numeric ID)
struct GitHubRepoDetails: Codable, Sendable {
    let id: Int  // This is the github_id we need
    let name: String
    let owner: GitHubOwner
    let description: String?

    struct GitHubOwner: Codable, Sendable {
        let login: String
    }
}
