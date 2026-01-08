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
    @Published var filterPeriod: TrendingPeriod = .weekly

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
        githubToken: String? = nil,  // No longer needed, kept for API compatibility
        completion: @escaping (Bool, String?) -> Void
    ) {
        print("🔍 [TrendingRepoManager] Starting fetchTrending for username: \(username)")
        print("🔍 [TrendingRepoManager] Filter language: \(filterLanguage ?? "nil"), period: \(filterPeriod.rawValue)")

        // Fetch uninteracted trending repos from backend (already filtered server-side)
        apiService.fetchUninteractedTrendingRepos(
            username: username,
            batchSize: 30,
            language: filterLanguage,
            period: filterPeriod
        ) { [weak self] response in
            guard let self = self else { return }

            guard let response = response else {
                print("❌ [TrendingRepoManager] Failed to fetch trending repos from backend")
                completion(false, "Failed to fetch trending repos")
                return
            }

            print("✅ [TrendingRepoManager] Fetched \(response.count) uninteracted trending repos from backend")

            // Convert API response to EnrichedTrendingRepo objects
            let enrichedRepos = response.repositories.map { apiRepo in
                EnrichedTrendingRepo(
                    trending: GitHubTrendingRepository(
                        author: apiRepo.owner,
                        name: apiRepo.name,
                        url: apiRepo.url ?? "",
                        description: apiRepo.description,
                        language: apiRepo.language,
                        languageColor: nil,
                        stars: apiRepo.stars,
                        forks: apiRepo.forks,
                        currentPeriodStars: 0,
                        builtBy: nil,
                        githubId: apiRepo.github_id
                    ),
                    githubId: apiRepo.github_id,
                    fetchedAt: Date()
                )
            }

            DispatchQueue.main.async {
                self.trendingRepos = enrichedRepos
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

    // Remove current repo from the list (used after successful interactions)
    func removeCurrentRepo() {
        print("🗑️ [TrendingRepoManager] removeCurrentRepo called - current index: \(currentIndex), total: \(trendingRepos.count)")
        guard currentIndex < trendingRepos.count else {
            print("❌ [TrendingRepoManager] Cannot remove - index out of bounds")
            return
        }

        let removedRepo = trendingRepos[currentIndex]
        print("🗑️ [TrendingRepoManager] Removing repo at index \(currentIndex): \(removedRepo.trending.author)/\(removedRepo.trending.name)")

        trendingRepos.remove(at: currentIndex)
        print("✅ [TrendingRepoManager] Removed repo. New total: \(trendingRepos.count), current index stays at: \(currentIndex)")

        // Save updated cache
        saveCacheToStorage()
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
            // Force synchronize to ensure data is written to disk immediately
            UserDefaults.standard.synchronize()
            print("💾 [TrendingRepoManager] Cache saved and synchronized - \(trendingRepos.count) repos")
        } else {
            print("❌ [TrendingRepoManager] Failed to encode cache")
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

        // Load cache - but note that repos should already be filtered
        // (they were filtered during initial fetch and updated as user interacted)
        print("✅ [TrendingRepoManager] Loading cache with \(batch.repositories.count) repos, index: \(batch.currentIndex)")
        DispatchQueue.main.async {
            self.trendingRepos = batch.repositories
            self.currentIndex = batch.currentIndex
            print("✅ [TrendingRepoManager] Cache loaded successfully on main thread - \(self.trendingRepos.count) repos at index \(self.currentIndex)")
        }
    }

    // Re-filter cached repos against latest user interactions (called on app launch)
    // Since backend handles filtering, this now just validates cache and returns count
    func refilterCachedRepos(username: String, completion: @escaping (Int) -> Void) {
        print("🔄 [TrendingRepoManager] Validating \(trendingRepos.count) cached repos")

        // With backend filtering, we trust the cache if it's valid
        // The cache is already filtered when fetched from backend
        // Just return the current count - if user wants fresh data, they can pull to refresh
        DispatchQueue.main.async {
            // Reset index if it's out of bounds
            if self.currentIndex >= self.trendingRepos.count && self.trendingRepos.count > 0 {
                self.currentIndex = 0
            }

            print("✅ [TrendingRepoManager] Cache validation complete. \(self.trendingRepos.count) repos available")
            completion(self.trendingRepos.count)
        }
    }

    func clearCache() {
        print("🗑️ [TrendingRepoManager] Clearing cache")
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
