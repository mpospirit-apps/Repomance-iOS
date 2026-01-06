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
    @State private var showInfo = false
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var toastMessage: String?
    @State private var showToast: Bool = false
    @State private var toastColor: Color = .clear
    @State private var shouldRefresh = false
    @State private var showNoConnection = false

    @AppStorage("rizzSoundEnabled") private var rizzSoundEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true

    // Computed property to check if any filters are active
    private var hasActiveFilters: Bool {
        trendingManager.filterLanguage != nil || trendingManager.filterPeriod != .daily
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
                        showInfo: $showInfo
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
                                    apiService.recordInteraction(
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

                                        // Record Star interaction only if GitHub star succeeded
                                        if let username = authManager.username {
                                            apiService.recordInteraction(
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
                                        // Show error if star failed
                                        self.toastMessage = "Failed to star repository"
                                        self.toastColor = .red
                                        self.showToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.showToast = false
                                        }
                                    }
                                }
                            }
                        )
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
                        TrendingBottomInfoView(
                            remainingCount: trendingManager.remainingCount,
                            selectedPeriod: trendingManager.filterPeriod,
                            selectedLanguage: trendingManager.filterLanguage
                        )
                    }
                }

                // Toast notification
                if showToast, let message = toastMessage {
                    VStack {
                        HStack(spacing: 8) {
                            Image(systemName: toastColor == Color.starColor ? "star.fill" : "xmark.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text(message)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(toastColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brutalistBorder, lineWidth: 2)
                        )
                        .brutalistShadow(BrutalistStyle.Shadow.cardBlack)
                        .padding(.top, 60)

                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: showToast)
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            TrendingFiltersView(onRefresh: $shouldRefresh)
        }
        .sheet(isPresented: $showInfo) {
            TrendingInfoView()
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
        
        // Convert to Repository model
        let repository = Repository(from: enrichedRepo)
        currentRepository = repository
        print("✅ [TrendingView] Set currentRepository: \(repository.owner)/\(repository.name)")

        // Create language info
        if let language = enrichedRepo.trending.language,
           let color = enrichedRepo.trending.languageColor {
            currentLanguages = [LanguageInfo(
                name: language,
                percentage: 100.0,
                color: color
            )]
            print("🎨 [TrendingView] Language info: \(language) (\(color))")
        } else {
            currentLanguages = []
            print("⚠️ [TrendingView] No language info available")
        }

        // Fetch README from GitHub
        if let githubToken = authManager.accessToken {
            print("📖 [TrendingView] Fetching README for \(repository.owner)/\(repository.name)")
            apiService.fetchGitHubReadme(
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

        isLoading = false
        print("✅ [TrendingView] loadFromCache complete")
    }

    // MARK: - Navigation

    private func loadNextRepository() {
        trendingManager.moveToNextRepo()

        if trendingManager.hasRepos {
            loadFromCache()
        } else {
            currentRepository = nil
            errorMessage = "You've seen all trending repos!"
        }
    }
}

// MARK: - Trending Info View

struct TrendingInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Trending")
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundColor(Color.textPrimary)

                            Text("Discover what's popular on GitHub right now. Trending repositories are updated frequently and reflect current developer interests.")
                                .font(.body)
                                .foregroundColor(Color.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Features")
                                .font(.headline)
                                .fontWeight(.heavy)
                                .foregroundColor(Color.textPrimary)

                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Real-time Trending",
                                description: "Discover repositories gaining popularity today, this week, or this month"
                            )

                            FeatureRow(
                                icon: "arrow.clockwise",
                                title: "Unlimited Browsing",
                                description: "No daily limits - explore as many trending repos as you want"
                            )

                            FeatureRow(
                                icon: "line.3.horizontal.decrease.circle",
                                title: "Smart Filtering",
                                description: "Filter by programming language and time period"
                            )

                            FeatureRow(
                                icon: "checkmark.circle",
                                title: "No Duplicates",
                                description: "Repos you've starred or passed won't appear again"
                            )
                        }

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.textPrimary)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.appAccent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(Color.textSecondary)
            }
        }
    }
}
