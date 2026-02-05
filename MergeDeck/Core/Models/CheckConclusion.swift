//
//  CheckConclusion.swift
//  MergeDeck
//

import Foundation

enum CheckConclusion: String, Codable {
    case success
    case failure
    case neutral
    case cancelled
    case skipped
    case timedOut
}
