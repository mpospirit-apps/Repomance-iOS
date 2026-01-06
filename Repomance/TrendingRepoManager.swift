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
        print("🎬 [TrendingRepoManager] Initializing TrendingRepoManager")
        // Load cache on init
        loadCacheFromStorage()
        print("🎬 [TrendingRepoManager] Initialization complete - hasRepos: \(hasRepos), count: \(trendingRepos.count)")
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
        print("🔍 [TrendingRepoManager] Starting fetchTrending for username: \(username)")
        print("🔍 [TrendingRepoManager] Filter language: \(filterLanguage ?? "nil"), period: \(filterPeriod.rawValue)")
        
        // Step 1: Fetch trending repos from API
        apiService.fetchTrendingRepositories(
            language: filterLanguage,
            since: filterPeriod,
            token: githubToken
        ) { [weak self] trendingRepos in
            guard let self = self, let trendingRepos = trendingRepos else {
                print("❌ [TrendingRepoManager] Failed to fetch trending repos from API")
                completion(false, "Failed to fetch trending repos")
                return
            }

            print("✅ [TrendingRepoManager] Fetched \(trendingRepos.count) trending repos from API")
            
            if trendingRepos.isEmpty {
                print("⚠️ [TrendingRepoManager] No trending repos returned from API")
                DispatchQueue.main.async {
                    self.trendingRepos = []
                    self.currentIndex = 0
                    self.saveCacheToStorage()
                    completion(true, nil)
                }
                return
            }

            // Step 2: Enrich with GitHub IDs and filter interacted repos
            print("🔄 [TrendingRepoManager] Starting enrichment process...")
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
        print("🔄 [TrendingRepoManager] Starting enrichAndFilter with \(trendingRepos.count) repos")

        // Fetch user's interactions first for filtering
        print("📥 [TrendingRepoManager] Fetching user interactions for username: \(username)")
        apiService.fetchUserInteractions(username: username) { [weak self] interactedGithubIds in
            guard let self = self else { return }

            print("✅ [TrendingRepoManager] User has \(interactedGithubIds.count) interactions")
            let interactedSet = Set(interactedGithubIds)

            // Filter trending repos using GitHub IDs from search results
            print("🔄 [TrendingRepoManager] Filtering trending repos (already have GitHub IDs from search)")
            var enrichedRepos: [EnrichedTrendingRepo] = []

            for (index, trending) in trendingRepos.enumerated() {
                if let githubId = trending.githubId {
                    print("📋 [TrendingRepoManager] [\(index+1)/\(trendingRepos.count)] Checking \(trending.author)/\(trending.name) - GitHub ID: \(githubId)")

                    // Only add if not already interacted with
                    if !interactedSet.contains(githubId) {
                        let enriched = EnrichedTrendingRepo(
                            trending: trending,
                            githubId: githubId,
                            fetchedAt: Date()
                        )
                        enrichedRepos.append(enriched)
                        print("➕ [TrendingRepoManager] Added \(trending.author)/\(trending.name) to enriched list (total: \(enrichedRepos.count))")
                    } else {
                        print("⏭️ [TrendingRepoManager] [\(index+1)/\(trendingRepos.count)] Skipping \(trending.author)/\(trending.name) - already interacted")
                    }
                } else {
                    print("⚠️ [TrendingRepoManager] [\(index+1)/\(trendingRepos.count)] No GitHub ID for \(trending.author)/\(trending.name)")
                }
            }

            DispatchQueue.main.async {
                print("🎯 [TrendingRepoManager] Filtering complete! Final count: \(enrichedRepos.count) repos")
                self.trendingRepos = enrichedRepos.sorted { $0.trending.stars > $1.trending.stars }
                self.currentIndex = 0
                self.saveCacheToStorage()
                print("💾 [TrendingRepoManager] Saved \(self.trendingRepos.count) repos to cache")

                if enrichedRepos.isEmpty {
                    print("⚠️ [TrendingRepoManager] No uninteracted trending repos found")
                    completion(true, "No uninteracted trending repos found")
                } else {
                    print("✅ [TrendingRepoManager] Successfully loaded \(enrichedRepos.count) trending repos")
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Navigation

    func getNextRepo() -> EnrichedTrendingRepo? {
        print("🎯 [TrendingRepoManager] getNextRepo called - hasRepos: \(hasRepos), currentIndex: \(currentIndex), total: \(trendingRepos.count)")
        
        guard hasRepos else {
            print("❌ [TrendingRepoManager] No repos available")
            return nil
        }
        
        let repo = trendingRepos[currentIndex]
        print("✅ [TrendingRepoManager] Returning repo at index \(currentIndex): \(repo.trending.author)/\(repo.trending.name)")
        return repo
    }

    func moveToNextRepo() {
        print("➡️ [TrendingRepoManager] moveToNextRepo called - current index: \(currentIndex)")
        guard hasRepos else {
            print("❌ [TrendingRepoManager] Cannot move, no repos available")
            return
        }
        currentIndex += 1
        print("✅ [TrendingRepoManager] Moved to index: \(currentIndex), remaining: \(remainingCount)")
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
        print("💾 [TrendingRepoManager] Attempting to load cache from storage")
        
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let batch = try? JSONDecoder().decode(CachedTrendingBatch.self, from: data) else {
            print("⚠️ [TrendingRepoManager] No cache found or failed to decode")
            return
        }

        print("📦 [TrendingRepoManager] Cache found with \(batch.repositories.count) repos, cached at \(batch.cachedAt)")
        
        // Check cache expiration (1 hour)
        let hoursSinceCached = Date().timeIntervalSince(batch.cachedAt) / 3600
        print("⏰ [TrendingRepoManager] Cache age: \(String(format: "%.2f", hoursSinceCached)) hours (max: \(cacheExpirationHours))")
        
        guard hoursSinceCached < cacheExpirationHours else {
            print("❌ [TrendingRepoManager] Cache expired, clearing...")
            clearCache()
            return
        }

        // Check if filters match
        print("🔍 [TrendingRepoManager] Comparing filters - cached language: \(batch.filterLanguage ?? "nil"), current: \(filterLanguage ?? "nil")")
        print("🔍 [TrendingRepoManager] Comparing filters - cached period: \(batch.filterPeriod.rawValue), current: \(filterPeriod.rawValue)")
        
        guard batch.filterLanguage == filterLanguage && batch.filterPeriod == filterPeriod else {
            print("❌ [TrendingRepoManager] Filters don't match, clearing cache...")
            clearCache()
            return
        }

        // Load cache
        print("✅ [TrendingRepoManager] Loading cache with \(batch.repositories.count) repos, index: \(batch.currentIndex)")
        DispatchQueue.main.async {
            self.trendingRepos = batch.repositories
            self.currentIndex = batch.currentIndex
            print("✅ [TrendingRepoManager] Cache loaded successfully on main thread")
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
