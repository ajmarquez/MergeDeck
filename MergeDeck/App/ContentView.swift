//
//  ContentView.swift
//  MergeDeck
//
//  Created by Abelardo Jesus Marquez Gonzalez on 05.02.26.
//

import SwiftUI

struct ContentView: View {
    @State private var hasToken = false

    var body: some View {
        Group {
            if hasToken {
                ConnectedView(onSignOut: handleSignOut)
            } else {
                AuthView(onAuthenticated: handleAuthenticated)
            }
        }
        .task {
            await refreshAuthenticationState()
        }
    }

    private func refreshAuthenticationState() async {
        let token = await KeychainManager().getToken()
        await MainActor.run {
            hasToken = token != nil
        }
    }

    private func handleAuthenticated() {
        hasToken = true
    }

    private func handleSignOut() {
        hasToken = false
    }
}

#Preview {
    ContentView()
}
