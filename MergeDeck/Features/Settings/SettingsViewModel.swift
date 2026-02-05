//
//  SettingsViewModel.swift
//  MergeDeck
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    let refreshIntervals = [5, 15, 30]

    func sanitizedRefreshInterval(_ value: Int) -> Int {
        refreshIntervals.contains(value) ? value : 15
    }
}
