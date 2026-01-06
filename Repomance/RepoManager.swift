import Foundation
import Combine

struct CachedBatch: Codable {
    let repositories: [APIRepository]
    let currentIndex: Int
    let batchSize: Int
    let filterCategories: [String]
    let filterMinStars: String
    let filterMaxStars: String
    let filterLanguages: [String]
    let username: String
    let createdAt: Date
    let lastUsedAt: Date
}

class RepoCache: ObservableObject {
    static let shared = RepoCache()

    @Published private var cachedRepos: [APIRepository] = []
    @Published var filterCategories: [String] = []
    @Published var filterMinStars: String = ""
    @Published var filterMaxStars: String = ""
    @Published var filterLanguages: [String] = []

    private var currentIndex = 0
    private let requestedBatchSize = 10
    private var actualBatchSize = 0
    private let cacheKey = "RepomanceCachedBatch"
    private let cacheExpirationHours = 24.0

    var batchSize: Int {
        return actualBatchSize
    }

    var remainingCount: Int {
        return cachedRepos.count - currentIndex
    }

    var currentPosition: Int {
        return currentIndex + 1 // Convert 0-based index to 1-based position
    }

    var hasRepos: Bool {
        return currentIndex < cachedRepos.count
    }

    // MARK: - Persistent Cache Management

    private func saveCacheToStorage(username: String) {
        let cachedBatch = CachedBatch(
            repositories: cachedRepos,
            currentIndex: currentIndex,
            batchSize: actualBatchSize,
            filterCategories: filterCategories,
            filterMinStars: filterMinStars,
            filterMaxStars: filterMaxStars,
            filterLanguages: filterLanguages,
            username: username,
            createdAt: getCacheCreationDate(),
            lastUsedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(cachedBatch) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    func loadCacheFromStorage(username: String) -> Bool {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cachedBatch = try? JSONDecoder().decode(CachedBatch.self, from: data) else {
            return false
        }

        // Check if cache is for the same user
        guard cachedBatch.username == username else {
            clearCache()
            return false
        }

        // Check if cache is from a different day (calendar day, not 24 hours)
        if !isSameDay(date1: cachedBatch.createdAt, date2: Date()) {
            clearCache()
            return false
        }

        // Also check the 24-hour expiration as a fallback
        let hoursAgo = Date().timeIntervalSince(cachedBatch.createdAt) / 3600
        if hoursAgo > cacheExpirationHours {
            clearCache()
            return false
        }

        // Check if filters have changed
        if !filtersMatch(cachedBatch: cachedBatch) {
            clearCache()
            return false
        }

        // Load the cached batch
        cachedRepos = cachedBatch.repositories
        currentIndex = cachedBatch.currentIndex
        actualBatchSize = cachedBatch.repositories.count

        // Update last used time
        updateLastUsedTime(username: username)

        return true
    }

    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    private func filtersMatch(cachedBatch: CachedBatch) -> Bool {
        return cachedBatch.filterCategories == filterCategories &&
               cachedBatch.filterMinStars == filterMinStars &&
               cachedBatch.filterMaxStars == filterMaxStars &&
               cachedBatch.filterLanguages == filterLanguages
    }

    private func getCacheCreationDate() -> Date {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cachedBatch = try? JSONDecoder().decode(CachedBatch.self, from: data) {
            return cachedBatch.createdAt
        }
        return Date()
    }

    private func updateLastUsedTime(username: String) {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cachedBatch = try? JSONDecoder().decode(CachedBatch.self, from: data) else {
            return
        }

        let updatedBatch = CachedBatch(
            repositories: cachedBatch.repositories,
            currentIndex: currentIndex,
            batchSize: cachedBatch.batchSize,
            filterCategories: cachedBatch.filterCategories,
            filterMinStars: cachedBatch.filterMinStars,
            filterMaxStars: cachedBatch.filterMaxStars,
            filterLanguages: cachedBatch.filterLanguages,
            username: cachedBatch.username,
            createdAt: cachedBatch.createdAt,
            lastUsedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(updatedBatch) {
            UserDefaults.standard.set(encoded, forKey: cacheKey)
        }
    }

    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
    
    func fetchBatch(username: String, userId: Int?, shouldLog: Bool = false, completion: @escaping (Bool) -> Void) {
        // First try to load from cache
        if loadCacheFromStorage(username: username) && hasRepos {
            completion(true)
            return
        }

        fetchBatchFromAPI(username: username, userId: userId, shouldLog: shouldLog, completion: completion)
    }

    private func fetchBatchFromAPI(username: String, userId: Int?, shouldLog: Bool = false, completion: @escaping (Bool) -> Void) {
        let minStars = Int(filterMinStars.isEmpty ? "" : filterMinStars)
        let maxStars = Int(filterMaxStars.isEmpty ? "" : filterMaxStars)
        let categories = filterCategories.isEmpty ? nil : filterCategories
        let languages = filterLanguages.isEmpty ? nil : filterLanguages

        CustomAPIService.shared.fetchUninteractedRepos(
            username: username,
            batchSize: requestedBatchSize,
            categories: categories,
            minStarCount: minStars,
            maxStarCount: maxStars,
            languages: languages
        ) { response in
            DispatchQueue.main.async {
                if let response = response {
                    self.cachedRepos.append(contentsOf: response.repositories)
                    self.actualBatchSize = self.cachedRepos.count

                    // Save to persistent cache
                    self.saveCacheToStorage(username: username)

                    // Log batch generation if requested and we have repos and userId
                    if shouldLog, let userId = userId {
                        CustomAPIService.shared.logBatchGeneration(userId: userId) { success in
                            // Complete after logging is done (success or failure)
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    } else {
                        // No logging needed, complete immediately
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func fetchNewBatch(username: String, userId: Int?, completion: @escaping (Bool) -> Void) {
        reset()
        clearCache()
        fetchBatchFromAPI(username: username, userId: userId, shouldLog: true, completion: completion)
    }

    func fetchBatchPreview(username: String, completion: @escaping (Int?) -> Void) {
        let minStars = Int(filterMinStars.isEmpty ? "" : filterMinStars)
        let maxStars = Int(filterMaxStars.isEmpty ? "" : filterMaxStars)
        let categories = filterCategories.isEmpty ? nil : filterCategories
        let languages = filterLanguages.isEmpty ? nil : filterLanguages
        
        CustomAPIService.shared.fetchUninteractedRepos(
            username: username,
            batchSize: 10, // fetch a full batch to check the count
            categories: categories,
            minStarCount: minStars,
            maxStarCount: maxStars,
            languages: languages
        ) { response in
            DispatchQueue.main.async {
                completion(response?.repositories.count)
            }
        }
    }
    
    func getNextRepo() -> APIRepository? {
        guard hasRepos else { return nil }
        let repo = cachedRepos[currentIndex]

        // Don't increment here - increment when we actually move to next repo
        return repo
    }

    func moveToNextRepo() {
        if hasRepos {
            currentIndex += 1

            // Update the cache with new currentIndex
            if let username = getCurrentUsername() {
                updateLastUsedTime(username: username)
            }
        }
    }

    private func getCurrentUsername() -> String? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cachedBatch = try? JSONDecoder().decode(CachedBatch.self, from: data) else {
            return nil
        }
        return cachedBatch.username
    }

    func hasValidCache(for username: String) -> Bool {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cachedBatch = try? JSONDecoder().decode(CachedBatch.self, from: data) else {
            return false
        }

        // Check user match
        guard cachedBatch.username == username else { return false }

        // Check if cache is from a different day
        if !isSameDay(date1: cachedBatch.createdAt, date2: Date()) { return false }

        // Check expiration (fallback)
        let hoursAgo = Date().timeIntervalSince(cachedBatch.createdAt) / 3600
        if hoursAgo > cacheExpirationHours { return false }

        // Check filters
        return filtersMatch(cachedBatch: cachedBatch)
    }
    
    func reset() {
        cachedRepos.removeAll()
        currentIndex = 0
        actualBatchSize = 0
    }

    func debugCacheStatus(for username: String) {
        // Debug function - no output in production
    }
}

