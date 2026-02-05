//
//  ConnectedViewModel.swift
//  MergeDeck
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ConnectedViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var pullRequestCount: Int = 0
    @Published var isLoading = false
    @Published var statusMessage: String?

    @AppStorage("githubBaseURL") private var baseURLString = GitHubAPIClient.defaultBaseURL.absoluteString
    private let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    convenience init() {
        self.init(tokenStore: KeychainManager())
    }

    func load() async {
        await refreshConnection(showSuccess: false)
    }

    func refreshConnection(showSuccess: Bool = true) async {
        guard let baseURL = URL(string: baseURLString) else {
            statusMessage = "Invalid base URL."
            return
        }

        isLoading = true
        statusMessage = nil

        do {
            let client = GitHubAPIClient(baseURL: baseURL, tokenStore: tokenStore)
            let login = try await client.fetchViewerLogin()
            let pullRequests = try await client.fetchMyPullRequests()

            self.login = login
            self.pullRequestCount = pullRequests.count

            if showSuccess {
                statusMessage = "Connection OK."
            }
        } catch {
            statusMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to refresh."
        }

        isLoading = false
    }
}
