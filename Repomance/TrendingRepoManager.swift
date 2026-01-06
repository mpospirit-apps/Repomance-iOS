//
//  TrendingRepoManager.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import Foundation
import SwiftUI
import Combine

class TrendingRepoManager: ObservableObject {
    static let shared = TrendingRepoManager()

    @Published var trendingRepos: [EnrichedTrendingRepo] = []
    @Published var filterLanguage: String? = nil
    @Published var filterPeriod: TrendingPeriod = .daily

    private var currentIndex = 0
    private let cacheKey = "RepomanceTrendingCache"
    private let cacheExpirationHours = 1.0  // Trending updates frequently
    private let apiService = CustomAPIService.shared

    private init() {
        // Load cache on init
        loadCacheFromStorage()
    }

    var hasRepos: Bool {
        return currentIndex < trendingRepos.count
    }

    var remainingCount: Int {
        return max(0, trendingRepos.count - currentIndex)
    }

    var currentPosition: Int {
        return currentIndex
    }

    // MARK: - Fetch Trending Repos

    func fetchTrending(
        username: String,
        githubToken: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // Step 1: Fetch trending repos from API
        apiService.fetchTrendingRepositories(
            language: filterLanguage,
            since: filterPeriod
        ) { [weak self] trendingRepos in
            guard let self = self, let trendingRepos = trendingRepos else {
                completion(false, "Failed to fetch trending repos")
                return
            }

            if trendingRepos.isEmpty {
                DispatchQueue.main.async {
                    self.trendingRepos = []
                    self.currentIndex = 0
                    self.saveCacheToStorage()
                    completion(true, nil)
                }
                return
            }

            // Step 2: Enrich with GitHub IDs and filter interacted repos
            self.enrichAndFilter(
                trendingRepos: trendingRepos,
                username: username,
                githubToken: githubToken,
                completion: completion
            )
        }
    }

    private func enrichAndFilter(
        trendingRepos: [GitHubTrendingRepository],
        username: String,
        githubToken: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let group = DispatchGroup()
        var enrichedRepos: [EnrichedTrendingRepo] = []
        let enrichmentQueue = DispatchQueue(label: "com.repomance.enrichment", attributes: .concurrent)
        let lock = NSLock()

        // Fetch user's interactions first for filtering
        apiService.fetchUserInteractions(username: username) { [weak self] interactedGithubIds in
            guard let self = self else { return }

            let interactedSet = Set(interactedGithubIds)

            // Enrich each trending repo with GitHub ID
            for trending in trendingRepos {
                group.enter()
                enrichmentQueue.async {
                    self.apiService.fetchGitHubRepoDetails(
                        owner: trending.author,
                        repo: trending.name,
                        token: githubToken
                    ) { githubId in
                        if let githubId = githubId {
                            // Only add if not already interacted with
                            if !interactedSet.contains(githubId) {
                                let enriched = EnrichedTrendingRepo(
                                    trending: trending,
                                    githubId: githubId,
                                    fetchedAt: Date()
                                )
                                lock.lock()
                                enrichedRepos.append(enriched)
                                lock.unlock()
                            }
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.trendingRepos = enrichedRepos.sorted { $0.trending.stars > $1.trending.stars }
                self.currentIndex = 0
                self.saveCacheToStorage()

                if enrichedRepos.isEmpty {
                    completion(true, "No uninteracted trending repos found")
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Navigation

    func getNextRepo() -> EnrichedTrendingRepo? {
        guard hasRepos else { return nil }
        return trendingRepos[currentIndex]
    }

    func moveToNextRepo() {
        guard hasRepos else { return }
        currentIndex += 1
    }

    func reset() {
        currentIndex = 0
        trendingRepos = []
        clearCache()
    }

    // MARK: - Caching

    private struct CachedTrendingBatch: Codable {
        let repositories: [EnrichedTrendingRepo]
        let currentIndex: Int
        let filterLanguage: String?
        let filterPeriod: TrendingPeriod
        let cachedAt: Date
    }

    private func saveCacheToStorage() {
        let batch = CachedTrendingBatch(
            repositories: trendingRepos,
            currentIndex: currentIndex,
            filterLanguage: filterLanguage,
            filterPeriod: filterPeriod,
            cachedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(batch) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    private func loadCacheFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let batch = try? JSONDecoder().decode(CachedTrendingBatch.self, from: data) else {
            return
        }

        // Check cache expiration (1 hour)
        let hoursSinceCached = Date().timeIntervalSince(batch.cachedAt) / 3600
        guard hoursSinceCached < cacheExpirationHours else {
            clearCache()
            return
        }

        // Check if filters match
        guard batch.filterLanguage == filterLanguage && batch.filterPeriod == filterPeriod else {
            clearCache()
            return
        }

        // Load cache
        DispatchQueue.main.async {
            self.trendingRepos = batch.repositories
            self.currentIndex = batch.currentIndex
        }
    }

    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        DispatchQueue.main.async {
            self.trendingRepos = []
            self.currentIndex = 0
        }
    }

    // MARK: - Filter Management

    func updateFilters(language: String?, period: TrendingPeriod) {
        let filtersChanged = (language != filterLanguage) || (period != filterPeriod)

        filterLanguage = language
        filterPeriod = period

        if filtersChanged {
            clearCache()
        }
    }
}
