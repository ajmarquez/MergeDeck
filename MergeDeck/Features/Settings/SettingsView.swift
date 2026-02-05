//
//  SettingsView.swift
//  MergeDeck
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("refreshIntervalMinutes") private var refreshIntervalMinutes = 15
    @AppStorage("useEnterprise") private var useEnterprise = false
    @AppStorage("githubBaseURL") private var githubBaseURL = GitHubAPIClient.defaultBaseURL.absoluteString

    var body: some View {
        Form {
            Section("Refresh") {
                Picker("Refresh Interval", selection: $refreshIntervalMinutes) {
                    ForEach(viewModel.refreshIntervals, id: \.self) { interval in
                        Text("\(interval) minutes")
                            .tag(interval)
                    }
                }
            }

            Section("GitHub") {
                Toggle("Use GitHub Enterprise", isOn: $useEnterprise)

                if useEnterprise {
                    TextField("https://github.company.com/graphql", text: $githubBaseURL)
                        .platformTextInput()
                        .platformURLKeyboard()
                } else {
                    LabeledContent("Endpoint") {
                        Text(GitHubAPIClient.defaultBaseURL.absoluteString)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Notes") {
                Text("Refresh interval is used for app updates and will be reused by widgets in Phase 3.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            refreshIntervalMinutes = viewModel.sanitizedRefreshInterval(refreshIntervalMinutes)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
