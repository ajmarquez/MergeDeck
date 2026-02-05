//
//  CIStatus.swift
//  MergeDeck
//

import Foundation

enum CIStatus: String, Codable {
    case pending
    case success
    case failure
    case neutral
    case unknown

    var icon: String {
        switch self {
        case .pending:
            return "clock.arrow.circlepath"
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "xmark.circle.fill"
        case .neutral:
            return "minus.circle.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }

    nonisolated init(statusCheckState: String?) {
        switch statusCheckState?.uppercased() {
        case "SUCCESS":
            self = .success
        case "FAILURE", "ERROR":
            self = .failure
        case "PENDING", "EXPECTED":
            self = .pending
        case "NEUTRAL":
            self = .neutral
        default:
            self = .unknown
        }
    }
}

extension Array where Element == PullRequest {
    var overallStatus: CIStatus {
        if isEmpty {
            return .unknown
        }
        if contains(where: { $0.ciStatus == .failure }) {
            return .failure
        }
        if contains(where: { $0.ciStatus == .pending }) {
            return .pending
        }
        if allSatisfy({ $0.ciStatus == .success }) {
            return .success
        }
        return .neutral
    }
}
