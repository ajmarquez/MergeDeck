//
//  PRListView.swift
//  MergeDeck
//

import SwiftUI

struct PRListView: View {
    @StateObject private var viewModel = PRListViewModel()
    @State private var isShowingSettings = false

    @AppStorage("refreshIntervalMinutes") private var refreshIntervalMinutes = 15
    @AppStorage("useEnterprise") private var useEnterprise = false
    @AppStorage("githubBaseURL") private var githubBaseURL = GitHubAPIClient.defaultBaseURL.absoluteString

    let onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.pullRequests.isEmpty {
                    ProgressView("Loading pull requests...")
                } else if viewModel.pullRequests.isEmpty {
                    ContentUnavailableView(
                        "No Open Pull Requests",
                        systemImage: "tray",
                        description: Text("You do not have open pull requests right now.")
                    )
                } else {
                    List(viewModel.pullRequests) { pullRequest in
                        NavigationLink {
                            PRDetailView(pullRequest: pullRequest)
                        } label: {
                            PRRowView(pullRequest: pullRequest)
                        }
                    }
                    .listStyle(.inset)
                    .refreshable {
                        await refresh(showLoading: false)
                    }
                }
            }
            .navigationTitle("My Pull Requests")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }

                ToolbarItem {
                    Button("Sign Out") {
                        Task {
                            try? await KeychainManager().deleteToken()
                            onSignOut()
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.red.opacity(0.15), in: Capsule())
                        .padding()
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if !viewModel.login.isEmpty {
                        Text("@\(viewModel.login)")
                    }

                    Spacer()

                    if let lastUpdated = viewModel.lastUpdated {
                        Text(lastUpdated, format: .dateTime.hour().minute())
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .sheet(isPresented: $isShowingSettings) {
                NavigationStack {
                    SettingsView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    isShowingSettings = false
                                }
                            }
                        }
                }
            }
        }
        .task {
            await refresh(showLoading: true)
        }
        .task(id: autoRefreshKey) {
            let intervalInSeconds = UInt64(max(refreshIntervalMinutes, 1)) * 60
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: intervalInSeconds * 1_000_000_000)
                await refresh(showLoading: false)
            }
        }
    }

    private var autoRefreshKey: String {
        "\(refreshIntervalMinutes)-\(useEnterprise)-\(githubBaseURL)"
    }

    private func refresh(showLoading: Bool) async {
        guard let baseURL = GitHubEndpoint.resolve(useEnterprise: useEnterprise, configuredBaseURL: githubBaseURL) else {
            await MainActor.run {
                viewModel.errorMessage = "Invalid base URL in settings."
                viewModel.isLoading = false
            }
            return
        }

        await viewModel.load(baseURL: baseURL, showLoading: showLoading)
    }
}

#Preview {
    PRListView(onSignOut: {})
}
