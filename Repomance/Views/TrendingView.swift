//
//  TrendingView.swift
//  Repomance
//
//  Created by Claude Code on 2026-01-06.
//

import SwiftUI

struct TrendingView: View {
    @Binding var selectedView: ContentView.ViewType
    @EnvironmentObject var authManager: GitHubAuthManager
    @StateObject private var trendingManager = TrendingRepoManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    private let apiService = CustomAPIService.shared

    @State private var currentRepository: Repository?
    @State private var currentLanguages: [LanguageInfo] = []
    @State private var currentReadme: String = ""
    @State private var dismissed = 0
    @State private var starred = 0
    @State private var showFilters = false
    @State private var showSettings = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var toastMessage: String?
    @State private var showToast: Bool = false
    @State private var toastColor: Color = .clear
    @State private var shouldRefresh = false
    @State private var showNoConnection = false
    @State private var swipeProgress: CGFloat = 0

    @AppStorage("rizzSoundEnabled") private var rizzSoundEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    // Computed property to check if any filters are active
    private var hasActiveFilters: Bool {
        trendingManager.filterLanguage != nil || trendingManager.filterPeriod != .weekly
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            if showNoConnection {
                NoConnectionView(onRetry: {
                    checkConnectionAndInitialize()
                })
            } else {
                VStack(spacing: 0) {
                    // Header
                    TrendingHeaderView(
                        selectedView: $selectedView,
                        hasActiveFilters: hasActiveFilters,
                        showFilters: $showFilters,
                        showSettings: $showSettings
                    )

                    // Card Stack
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color.appAccent)
                            Text("Loading trending repos...")
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
                                    print("📝 [TrendingView] Recording Pass interaction for repo \(repository.id)")
                                    apiService.recordInteraction(
                                        username: username,
                                        githubRepoId: repository.id,
                                        interactionName: "Pass"
                                    ) { success in
                                        if success {
                                            print("✅ [TrendingView] Pass interaction recorded successfully for repo \(repository.id)")
                                        } else {
                                            print("⚠️ [TrendingView] Failed to record Pass interaction for repo \(repository.id)")
                                            // Show warning toast to user
                                            DispatchQueue.main.async {
                                                self.toastMessage = "Warning: Interaction not saved"
                                                self.toastColor = .orange
                                                self.showToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    self.showToast = false
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("⚠️ [TrendingView] Cannot record Pass interaction - username is nil")
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

                                        // Record Star interaction only if GitHub star succeeded
                                        if let username = authManager.username {
                                            print("📝 [TrendingView] Recording Star interaction for repo \(repository.id)")
                                            apiService.recordInteraction(
                                                username: username,
                                                githubRepoId: repository.id,
                                                interactionName: "Star"
                                            ) { success in
                                                if success {
                                                    print("✅ [TrendingView] Star interaction recorded successfully for repo \(repository.id)")
                                                } else {
                                                    print("⚠️ [TrendingView] Failed to record Star interaction for repo \(repository.id)")
                                                    // Show warning toast to user
                                                    DispatchQueue.main.async {
                                                        self.toastMessage = "Starred, but interaction not saved"
                                                        self.toastColor = .orange
                                                        self.showToast = true
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                            self.showToast = false
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            print("⚠️ [TrendingView] Cannot record Star interaction - username is nil")
                                        }

                                        starred += 1
                                        loadNextRepository()
                                    } else {
                                        // Show error if star failed
                                        self.toastMessage = "Failed to star repository"
                                        self.toastColor = .red
                                        self.showToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.showToast = false
                                        }
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
                        TrendingEmptyStateView(
                            isLoading: isLoading,
                            loadTrending: {
                                loadTrendingRepos()
                            },
                            errorMessage: errorMessage
                        )
                    }

                    // Bottom info
                    if currentRepository != nil {
                        // Push bottom info to the bottom
                        Spacer()

                        TrendingBottomInfoView(
                            remainingCount: trendingManager.remainingCount,
                            selectedPeriod: trendingManager.filterPeriod,
                            selectedLanguage: trendingManager.filterLanguage,
                            showToast: showToast,
                            toastMessage: toastMessage,
                            toastColor: toastColor,
                            swipeProgress: swipeProgress
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            TrendingFiltersView(onRefresh: $shouldRefresh)
                .presentationCornerRadius(0)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationCornerRadius(0)
        }
        .onAppear {
            print("👀 [TrendingView] onAppear triggered")
            checkConnectionAndInitialize()
        }
        .onChange(of: shouldRefresh) { _, newValue in
            print("🔄 [TrendingView] shouldRefresh changed to: \(newValue)")
            if newValue {
                print("🔄 [TrendingView] Triggering loadTrendingRepos due to refresh")
                loadTrendingRepos()
                shouldRefresh = false
            }
        }
    }

    // MARK: - Initialization

    private func checkConnectionAndInitialize() {
        print("🔌 [TrendingView] checkConnectionAndInitialize called")
        print("🔌 [TrendingView] Network connected: \(networkMonitor.isConnected)")
        
        if !networkMonitor.isConnected {
            print("⚠️ [TrendingView] No connection, showing no connection view")
            showNoConnection = true
            return
        }

        showNoConnection = false

        // Load from cache or fetch new
        if trendingManager.hasRepos {
            print("📦 [TrendingView] TrendingManager has repos (\(trendingManager.remainingCount) remaining), loading from cache")
            loadFromCache()
        } else {
            print("🔄 [TrendingView] TrendingManager has no repos, auto-fetching trending repos")
            loadTrendingRepos()
        }
    }

    // MARK: - Load Trending Repos

    private func loadTrendingRepos() {
        print("🚀 [TrendingView] loadTrendingRepos called")
        
        guard let username = authManager.username,
              let githubToken = authManager.accessToken else {
            print("❌ [TrendingView] Missing authentication - username: \(authManager.username ?? "nil"), token: \(authManager.accessToken != nil ? "present" : "nil")")
            errorMessage = "Authentication required"
            isLoading = false
            return
        }

        print("✅ [TrendingView] Authentication OK - username: \(username)")
        
        isLoading = true
        errorMessage = nil
        currentRepository = nil

        print("🔄 [TrendingView] Calling trendingManager.fetchTrending...")
        trendingManager.fetchTrending(
            username: username,
            githubToken: githubToken
        ) { success, error in
            print("📬 [TrendingView] fetchTrending callback - success: \(success), error: \(error ?? "nil")")
            
            DispatchQueue.main.async {
                self.isLoading = false

                if success {
                    if let error = error {
                        print("⚠️ [TrendingView] Success with message: \(error)")
                        self.errorMessage = error
                    } else if trendingManager.hasRepos {
                        print("✅ [TrendingView] Has repos, loading from cache...")
                        self.loadFromCache()
                    } else {
                        print("⚠️ [TrendingView] No trending repos found")
                        self.errorMessage = "No trending repos found"
                    }
                } else {
                    print("❌ [TrendingView] Failed to load trending repos: \(error ?? "unknown error")")
                    self.errorMessage = error ?? "Failed to load trending repos"
                }
            }
        }
    }

    // MARK: - Load from Cache

    private func loadFromCache() {
        print("📦 [TrendingView] loadFromCache called")

        guard let enrichedRepo = trendingManager.getNextRepo() else {
            print("❌ [TrendingView] No repo available from trendingManager")
            currentRepository = nil
            isLoading = false
            return
        }

        print("✅ [TrendingView] Got repo from manager: \(enrichedRepo.trending.author)/\(enrichedRepo.trending.name)")

        // Keep loading state while saving repo
        isLoading = true

        // Save trending repo to database first (required for interactions to work)
        print("💾 [TrendingView] Saving trending repo to database before displaying...")
        apiService.saveTrendingRepo(
            githubId: enrichedRepo.githubId,
            owner: enrichedRepo.trending.author,
            name: enrichedRepo.trending.name,
            description: enrichedRepo.trending.description,
            stars: enrichedRepo.trending.stars,
            forks: enrichedRepo.trending.forks,
            language: enrichedRepo.trending.language,
            url: enrichedRepo.trending.url
        ) { success in
            DispatchQueue.main.async {
                if success {
                    print("✅ [TrendingView] Trending repo saved to database successfully")
                } else {
                    print("⚠️ [TrendingView] Failed to save trending repo to database - interactions may fail")
                }

                // Only display repo AFTER it's been saved to database
                let repository = Repository(from: enrichedRepo)
                self.currentRepository = repository
                print("✅ [TrendingView] Set currentRepository: \(repository.owner)/\(repository.name)")

                // Create language info
                if let language = enrichedRepo.trending.language {
                    let color = self.languageColor(for: language)
                    self.currentLanguages = [LanguageInfo(
                        name: language,
                        percentage: 100.0,
                        color: color
                    )]
                    print("🎨 [TrendingView] Language info: \(language) (\(color))")
                } else {
                    self.currentLanguages = []
                    print("⚠️ [TrendingView] No language info available")
                }

                // Fetch README from GitHub
                if let githubToken = self.authManager.accessToken {
                    print("📖 [TrendingView] Fetching README for \(repository.owner)/\(repository.name)")
                    self.apiService.fetchGitHubReadme(
                        owner: repository.owner,
                        repo: repository.name,
                        token: githubToken
                    ) { readme in
                        DispatchQueue.main.async {
                            self.currentReadme = readme ?? ""
                            print("✅ [TrendingView] README loaded, length: \(self.currentReadme.count) chars")
                        }
                    }
                } else {
                    print("⚠️ [TrendingView] No GitHub token available for README fetch")
                }

                self.isLoading = false
                print("✅ [TrendingView] loadFromCache complete")
            }
        }
    }

    // MARK: - Navigation

    private func loadNextRepository() {
        trendingManager.moveToNextRepo()
        swipeProgress = 0 // Reset swipe progress for new card

        if trendingManager.hasRepos {
            loadFromCache()
        } else {
            currentRepository = nil
            errorMessage = "You've seen all trending repos!"
        }
    }

    // MARK: - Language Color Mapping

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
}
