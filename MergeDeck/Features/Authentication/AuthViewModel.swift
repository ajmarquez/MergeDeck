//
//  AuthViewModel.swift
//  MergeDeck
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    enum AuthMode: String, CaseIterable, Identifiable {
        case oauth
        case personalAccessToken

        var id: String { rawValue }

        var title: String {
            switch self {
            case .oauth:
                return "OAuth"
            case .personalAccessToken:
                return "Personal Access Token"
            }
        }
    }

    @Published var token: String = ""
    @Published var oauthClientID: String = ""
    @Published var authMode: AuthMode = .oauth
    @Published var isSaving = false
    @Published var isAuthorizingOAuth = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var oauthVerificationURL: URL?
    @Published var oauthUserCode: String?

    private let tokenStore: TokenStore

    init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    convenience init() {
        self.init(tokenStore: KeychainManager())
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

    func startOAuth(baseURL: URL, oauthBaseURL: URL) async -> Bool {
        let trimmedClientID = oauthClientID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedClientID.isEmpty else {
            errorMessage = "OAuth Client ID is required."
            return false
        }

        isAuthorizingOAuth = true
        errorMessage = nil
        successMessage = nil
        oauthVerificationURL = nil
        oauthUserCode = nil

        do {
            let oauth = GitHubOAuthClient(baseURL: oauthBaseURL, clientID: trimmedClientID)
            let authorization = try await oauth.startDeviceAuthorization()

            oauthVerificationURL = authorization.verificationURIComplete ?? authorization.verificationURI
            oauthUserCode = authorization.userCode

            let token = try await oauth.pollForAccessToken(authorization: authorization)
            try await tokenStore.setToken(token)

            let client = GitHubAPIClient(baseURL: baseURL, tokenStore: tokenStore)
            _ = try await client.fetchViewerLogin()

            successMessage = "OAuth connected successfully."
            isAuthorizingOAuth = false
            return true
        } catch {
            try? await tokenStore.deleteToken()
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "OAuth failed."
            isAuthorizingOAuth = false
            return false
        }
    }
}
