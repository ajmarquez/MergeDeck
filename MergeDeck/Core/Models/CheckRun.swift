//
//  CheckRun.swift
//  MergeDeck
//

import Foundation

struct CheckRun: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let status: CheckStatus
    let conclusion: CheckConclusion?
    let detailsURL: URL?
}
