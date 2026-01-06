//
//  SwipeView.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 5.12.2025.
//

import SwiftUI

struct SwipeView: View {
    @EnvironmentObject var authManager: GitHubAuthManager
    private let apiService = CustomAPIService.shared
    @StateObject private var repoCache = RepoCache.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var currentRepository: Repository?
    @State private var currentLanguages: [LanguageInfo] = []
    @State private var currentReadme: String = ""
    @State private var currentRepoId: Int?
    @State private var dismissed = 0
    @State private var starred = 0
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showRateLimitInfo = false
    @State private var showFilters = false
    @State private var showBatchInfo = false
    @State private var isLoading = true
    @State private var isGeneratingBatch = false
    @State private var noReposFound = false
    @State private var newBatchGenerated = false
    @State private var hasInitiallyLoaded = false
    @State private var dailyBatchCount: Int = 0
    @State private var showNoConnection = false
    @AppStorage("rizzSoundEnabled") private var rizzSoundEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @State private var remainingTime: String = "" // New state for remaining time
    @State private var toastMessage: String?
    @State private var showToast: Bool = false
    @State private var toastColor: Color = .clear
    @State private var swipeProgress: CGFloat = 0

    // Timer for updating remaining time
    @State private var timer: Timer?


    // Computed property to check if any filters are active
    private var hasActiveFilters: Bool {
        !repoCache.filterCategories.isEmpty ||
        !repoCache.filterMinStars.isEmpty ||
        !repoCache.filterMaxStars.isEmpty
    }

    // Check if user has reached batch limit
    private var hasReachedBatchLimit: Bool {
        return dailyBatchCount >= 10
    }

    var body: some View {
        ZStack {
            // GitHub Dark Theme background
            Color.appBackground
                .ignoresSafeArea()

            if showNoConnection {
                // No Connection View
                NoConnectionView(onRetry: {
                    checkConnectionAndInitialize()
                })
            } else {
                VStack(spacing: 0) {
                    // Header
                    SwipeHeaderView(
                        hasActiveFilters: hasActiveFilters,
                        showAbout: $showAbout,
                        showFilters: $showFilters,
                        showSettings: $showSettings
                    )

                    // Card Stack
                    if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.appAccent)
                        Text("Loading repository...")
                            .font(.system(.subheadline))
                            .fontWeight(.bold)
                            .foregroundColor(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let repository = currentRepository {
                    SwipeCard(
                        content: {
                            RepositoryCard(
                                repository: repository,
                                languages: currentLanguages,
                                readme: currentReadme
                            )
                        },
                        onSwipeLeft: {
                            // Haptic feedback for pass
                            if hapticFeedbackEnabled {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }

                            dismissed += 1
                            self.toastMessage = "Passed \(repository.name)"
                            self.toastColor = Color.passColor
                            self.showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showToast = false
                            }

                            // Record Pass interaction
                            if let username = authManager.username {
                                CustomAPIService.shared.recordInteraction(
                                    username: username,
                                    githubRepoId: repository.id,
                                    interactionName: "Pass"
                                ) { success in
                                    // Interaction recorded
                                }
                            }

                            loadNextRepository()
                        },
                        onSwipeRight: {
                            if rizzSoundEnabled {
                                SoundManager.shared.playRizzSound()
                            }

                            // Star on GitHub
                            authManager.starRepository(owner: repository.ownerName, repo: repository.name) { success in
                                if success {
                                    // Haptic feedback for successful star
                                    if hapticFeedbackEnabled {
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                    }

                                    self.toastMessage = "Starred \(repository.name)"
                                    self.toastColor = Color.starColor
                                    self.showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.showToast = false
                                    }

                                    // Record Star interaction in API only if GitHub star succeeded
                                    if let username = authManager.username {
                                        CustomAPIService.shared.recordInteraction(
                                            username: username,
                                            githubRepoId: repository.id,
                                            interactionName: "Star"
                                        ) { success in
                                            // Interaction recorded
                                        }
                                    }

                                    starred += 1
                                    loadNextRepository()
                                } else {
                                    // Haptic feedback for failed star
                                    if hapticFeedbackEnabled {
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.error)
                                    }

                                    self.toastMessage = "Failed to star \(repository.name)"
                                    self.toastColor = Color.passColor
                                    self.showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        self.showToast = false
                                    }
                                    // Still load next repository even if star failed, but don't record or increment
                                    loadNextRepository()
                                }
                            }
                        },
                        onSwipeProgress: { progress in
                            self.swipeProgress = progress
                        }
                    )
                    .id(repository.id)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .identity
                    ))
                } else {
                    // If batch limit is reached, always show limit reached UI regardless of noReposFound
                    if hasReachedBatchLimit {
                        BatchLimitView(
                            dailyBatchCount: dailyBatchCount,
                            remainingTime: remainingTime
                        )
                    } else {
                        EmptyStateView(
                            noReposFound: noReposFound,
                            isGeneratingBatch: isGeneratingBatch,
                            dailyBatchCount: dailyBatchCount,
                            generateNewBatch: generateNewBatch
                        )
                    }
                }

                // Remaining repos count at bottom
                if currentRepository != nil {
                    NotificationCountView(
                        showToast: showToast,
                        toastMessage: toastMessage,
                        toastColor: toastColor,
                        repoCache: repoCache,
                        dailyBatchCount: dailyBatchCount,
                        swipeProgress: swipeProgress,
                        showBatchInfo: $showBatchInfo
                    )
                }
            }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationCornerRadius(0)
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
                .presentationCornerRadius(0)
        }
        .sheet(isPresented: $showFilters) {
            FiltersView(newBatchGenerated: $newBatchGenerated, dailyBatchCount: dailyBatchCount)
                .presentationCornerRadius(0)
        }
        .sheet(isPresented: $showBatchInfo) {
            BatchInfoView()
                .presentationCornerRadius(0)
        }
        .onChange(of: showFilters) { _, isShowing in
            // When filters sheet closes after generating new batch
            if !isShowing && newBatchGenerated {
                newBatchGenerated = false

                // Clear current repo and load new filtered batch
                currentRepository = nil

                if repoCache.hasRepos {
                    // Has repos - load first one
                    loadFromCache()
                } else {
                    // No repos - show empty state with noReposFound flag
                    noReposFound = true
                }
            }
        }
        .onAppear {
            // Only reset and fetch on initial load, not when returning from browser
            if !hasInitiallyLoaded {
                hasInitiallyLoaded = true

                // Check for internet connection first
                if !networkMonitor.isConnected {
                    showNoConnection = true
                    isLoading = false
                } else {
                    checkConnectionAndInitialize()
                }
            }
            // Start timer to update remaining time
            self.calculateRemainingTime()
            self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                self.calculateRemainingTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: authManager.username) { _, newUsername in
            // Load cache when username becomes available
            if let username = newUsername, currentRepository == nil {
                fetchDailyBatchCount()

                // Check if we have a valid cache (including completed batches)
                if repoCache.hasValidCache(for: username) {
                    // Load cache state directly without fetching from API
                    let cacheLoaded = repoCache.loadCacheFromStorage(username: username)
                    if cacheLoaded && self.repoCache.hasRepos {
                        // Has repos - load first one
                        self.loadFromCache()
                    } else {
                        // Batch is complete, show empty state
                        self.isLoading = false
                    }
                } else {
                    // No valid cache - show empty state, user must generate batch manually
                    self.isLoading = false
                }
            }
        }
    }

    private func loadNextRepository() {
        // Move to next repo in cache first
        repoCache.moveToNextRepo()

        isLoading = true
        noReposFound = false
        currentRepository = nil
        currentLanguages = []
        currentReadme = "No README available"
        currentRepoId = nil

        // Check if we have repos in cache
        if !repoCache.hasRepos {
            // No repos available, show empty state
            isLoading = false
            return
        }

        loadFromCache()
    }

    private func generateNewBatch() {
        guard let username = authManager.username else {
            return
        }

        // Check if user has reached batch limit
        if hasReachedBatchLimit {
            return
        }

        isGeneratingBatch = true
        noReposFound = false
        repoCache.fetchNewBatch(username: username, userId: authManager.userId) { success in
            self.isGeneratingBatch = false
            if success {
                // Small delay to ensure server processed the batch logging
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.fetchDailyBatchCount()
                }
                if self.repoCache.hasRepos {
                    self.loadFromCache()
                } else {
                    // API returned success but no repos
                    self.noReposFound = true
                }
            }
        }
    }

    private func fetchDailyBatchCount() {
        CustomAPIService.shared.fetchDailyBatchCount { count in
            if let count = count {
                self.dailyBatchCount = count
            }
        }
    }

    private func checkConnectionAndInitialize() {
        // Check connection again
        if !networkMonitor.isConnected {
            showNoConnection = true
            isLoading = false
            return
        }

        // Connection is available, hide no connection screen
        showNoConnection = false

        // Wait for username to be available before loading
        if let username = authManager.username {
            fetchDailyBatchCount()

            // Check if we have a valid cache (including completed batches)
            if repoCache.hasValidCache(for: username) {
                // Load cache state directly without fetching from API
                let cacheLoaded = repoCache.loadCacheFromStorage(username: username)
                if cacheLoaded && self.repoCache.hasRepos {
                    // Has repos - load first one
                    self.loadFromCache()
                } else {
                    // Batch is complete, show empty state
                    self.isLoading = false
                }
            } else {
                // No valid cache - show empty state, user must generate batch manually
                repoCache.reset()
                self.isLoading = false
            }
        } else {
            // Show loading while waiting for username
            isLoading = true
        }
    }

    private func loadFromCache() {
        guard let apiRepo = repoCache.getNextRepo() else {
            isLoading = false
            return
        }

        let repository = Repository(from: apiRepo)

        // Convert languages from [String: Int] to [LanguageInfo]
        let total = apiRepo.languages.values.reduce(0, +)
        var languages: [LanguageInfo] = []

        if total > 0 {
            languages = apiRepo.languages.map { name, bytes in
                let percentage = Double(bytes) / Double(total) * 100
                return LanguageInfo(
                    name: name,
                    percentage: percentage,
                    color: self.languageColor(for: name)
                )
            }.sorted { $0.percentage > $1.percentage }
        }

        withAnimation {
            self.currentRepository = repository
            self.currentLanguages = languages
            self.isLoading = false
            self.swipeProgress = 0 // Reset swipe progress for new card
        }

        // Fetch README asynchronously
        CustomAPIService.shared.fetchReadme(id: apiRepo.id) { readme in
            if let readme = readme {
                self.currentReadme = readme
            }
        }
    }

    private func languageColor(for language: String) -> String {
        let colorPalette: [String] = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8",
            "#F7DC6F", "#BB8FCE", "#85C1E2", "#F8B88B", "#AAB7B8"
        ]

        let knownColors: [String: String] = [
            "Swift": "#F05138", "JavaScript": "#F7DF1E", "TypeScript": "#3178C6",
            "Python": "#3776AB", "Java": "#007396", "Kotlin": "#7F52FF",
            "Go": "#00ADD8", "Rust": "#DEA584", "Ruby": "#CC342D", "C++": "#00599C",
            "C": "#555555", "C#": "#239120", "PHP": "#777BB4", "HTML": "#E34F26",
            "CSS": "#1572B6", "Dart": "#0175C2", "Objective-C": "#438EFF"
        ]

        if let knownColor = knownColors[language] {
            return knownColor
        }

        let hash = language.hash
        let index = abs(hash) % colorPalette.count
        return colorPalette[index]
    }

    private func calculateRemainingTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: Date())
        components.day! += 1 // Get next day
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard let nextMidnightUTC = calendar.date(from: components) else { return }

        let remaining = nextMidnightUTC.timeIntervalSinceNow

        if remaining <= 0 {
            remainingTime = "You can relaunch the app to get your new batch."
        } else {
            let hours = Int(remaining) / 3600
            let minutes = (Int(remaining) % 3600) / 60

            if hours > 0 {
                remainingTime = String(format: "%d hours %02d minutes", hours, minutes)
            } else {
                remainingTime = String(format: "%d minutes", minutes)
            }
        }
    }
}




#Preview {
    SwipeView()
}
