//
//  GitHubEndpoint.swift
//  MergeDeck
//

import Foundation

enum GitHubEndpoint {
    static func resolve(useEnterprise: Bool, configuredBaseURL: String) -> URL? {
        if !useEnterprise {
            return GitHubAPIClient.defaultBaseURL
        }

        let trimmed = configuredBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        if trimmed.lowercased().hasSuffix("/graphql") {
            return URL(string: trimmed)
        }

        let base = trimmed.hasSuffix("/") ? String(trimmed.dropLast()) : trimmed
        return URL(string: "\(base)/graphql")
    }
}
