//
//  ConnectedView.swift
//  MergeDeck
//

import SwiftUI

struct ConnectedView: View {
    @StateObject private var viewModel = ConnectedViewModel()

    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Connected")
                .font(.largeTitle)

            if !viewModel.login.isEmpty {
                Text("Signed in as \(viewModel.login)")
                    .foregroundStyle(.secondary)
            }

            Text("Open PRs: \(viewModel.pullRequestCount)")
                .font(.title3)

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .foregroundStyle(viewModel.statusMessage == "Connection OK." ? .green : .red)
            }

            Button {
                Task {
                    await viewModel.refreshConnection()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Test Connection")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Sign Out") {
                Task {
                    try? await KeychainManager().deleteToken()
                    onSignOut()
                }
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.secondary)
        }
        .padding()
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    ConnectedView(onSignOut: {})
}
