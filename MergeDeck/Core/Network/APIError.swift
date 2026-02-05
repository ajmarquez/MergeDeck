//
//  APIError.swift
//  MergeDeck
//

import Foundation

enum APIError: Error, LocalizedError {
    case notAuthenticated
    case invalidResponse
    case unauthorized
    case rateLimited
    case httpError(Int)
    case decodingFailed
    case invalidURL
    case graphQLError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "No authentication token found."
        case .invalidResponse:
            return "Invalid server response."
        case .unauthorized:
            return "Unauthorized. Check your token."
        case .rateLimited:
            return "Rate limited by GitHub."
        case .httpError(let code):
            return "HTTP error: \(code)."
        case .decodingFailed:
            return "Failed to decode server response."
        case .invalidURL:
            return "Invalid URL provided."
        case .graphQLError(let message):
            return message
        }
    }
}
