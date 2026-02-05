//
//  CIStatus+Color.swift
//  MergeDeck
//

import SwiftUI

extension CIStatus {
    @MainActor
    var color: Color {
        switch self {
        case .pending:
            return .yellow
        case .success:
            return .green
        case .failure:
            return .red
        case .neutral:
            return .gray
        case .unknown:
            return .secondary
        }
    }
}
