//
//  PRListViewModel.swift
//  MergeDeck
//

import Foundation
import Combine

@MainActor
final class PRListViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var pullRequests: [PullRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    private let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    convenience init() {
        self.init(tokenStore: KeychainManager())
    }

    func load(baseURL: URL, showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil

        do {
            let client = GitHubAPIClient(baseURL: baseURL, tokenStore: tokenStore)
            async let login = client.fetchViewerLogin()
            async let pullRequests = client.fetchMyPullRequests()

            let loadedLogin = try await login
            let loadedPullRequests = try await pullRequests

            self.login = loadedLogin
            self.pullRequests = loadedPullRequests.sorted(by: { $0.updatedAt > $1.updatedAt })
            self.lastUpdated = .now
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to fetch pull requests."
        }

        isLoading = false
    }
}
