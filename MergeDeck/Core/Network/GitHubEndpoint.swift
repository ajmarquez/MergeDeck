//
//  GitHubEndpoint.swift
//  MergeDeck
//

import Foundation

enum GitHubEndpoint {
    static let defaultOAuthBaseURL = URL(string: "https://github.com")!

    static func resolve(useEnterprise: Bool, configuredBaseURL: String) -> URL? {
        if !useEnterprise {
            return GitHubAPIClient.defaultBaseURL
        }

        let trimmed = configuredBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        guard var components = URLComponents(string: trimmed), components.scheme != nil else {
            return nil
        }

        let path = components.path.lowercased()
        if path.hasSuffix("/graphql") || path.hasSuffix("/api/graphql") {
            return components.url
        }

        components.path = "/api/graphql"
        components.query = nil
        components.fragment = nil
        return components.url
    }

    static func resolveOAuthBase(useEnterprise: Bool, configuredBaseURL: String) -> URL? {
        if !useEnterprise {
            return defaultOAuthBaseURL
        }

        guard let graphqlURL = resolve(useEnterprise: true, configuredBaseURL: configuredBaseURL),
              var components = URLComponents(url: graphqlURL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }

        components.path = ""
        components.query = nil
        components.fragment = nil
        return components.url
    }
}
