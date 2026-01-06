//
//  GitHubService.swift
//  Repomance
//
//  Created by Cagri Gokpunar on 9.12.2025.
//

import Foundation
import Combine

class GitHubService: ObservableObject {
    static let shared = GitHubService()
    
    private let baseURL = Config.githubApiBaseUrl
    
    @Published var rateLimitRemaining: Int = 60
    @Published var rateLimitTotal: Int = 60
    @Published var isLoadingRateLimit: Bool = true
    
    func checkRateLimit(completion: @escaping @Sendable () -> Void) {
        let urlString = "\(baseURL)/rate_limit"
        guard let url = URL(string: urlString) else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse,
               let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
               let limit = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit"),
               let remainingInt = Int(remaining),
               let limitInt = Int(limit) {
                DispatchQueue.main.async {
                    self.rateLimitRemaining = remainingInt
                    self.rateLimitTotal = limitInt
                    self.isLoadingRateLimit = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoadingRateLimit = false
                }
            }
            completion()
        }.resume()
    }
    
    
    
    
    
    
}
