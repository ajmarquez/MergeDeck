//
//  TokenStore.swift
//  MergeDeck
//

import Foundation

protocol TokenStore {
    func getToken() async -> String?
    func setToken(_ token: String) async throws
    func deleteToken() async throws
}
