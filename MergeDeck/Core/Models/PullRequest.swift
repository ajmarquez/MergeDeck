//
//  PullRequest.swift
//  MergeDeck
//

import Foundation

struct PullRequest: Identifiable, Codable, Equatable {
    let id: String
    let number: Int
    let title: String
    let url: URL
    let repository: Repository
    let createdAt: Date
    let updatedAt: Date
    let isDraft: Bool
    let ciStatus: CIStatus
    let checkRuns: [CheckRun]

    var failedChecks: [CheckRun] {
        checkRuns.filter { $0.conclusion == .failure }
    }
}
