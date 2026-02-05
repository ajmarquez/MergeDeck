//
//  AuthViewModel.swift
//  MergeDeck
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var token: String = ""
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let tokenStore: TokenStore

    init(tokenStore: TokenStore = KeychainManager.shared) {
        self.tokenStore = tokenStore
    }

    func saveToken(baseURL: URL) async -> Bool {
        guard !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Token cannot be empty."
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        do {
            try await tokenStore.setToken(token)
            let client = GitHubAPIClient(baseURL: baseURL, tokenStore: tokenStore)
            _ = try await client.fetchMyPullRequests()
            successMessage = "Connected successfully."
            isSaving = false
            return true
        } catch {
            try? await tokenStore.deleteToken()
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Authentication failed."
            isSaving = false
            return false
        }
    }
}
