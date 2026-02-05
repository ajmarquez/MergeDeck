//
//  AuthView.swift
//  MergeDeck
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @AppStorage("useEnterprise") private var useEnterprise = false
    @AppStorage("githubBaseURL") private var enterpriseBaseURL = ""

    let onAuthenticated: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("MergeDeck")
                    .font(.largeTitle)
                Text("Connect with a GitHub token")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                SecureField("Personal Access Token", text: $viewModel.token)
                    .platformTextInput()

                Toggle("Use GitHub Enterprise", isOn: $useEnterprise)

                if useEnterprise {
                    TextField("https://github.company.com/graphql", text: $enterpriseBaseURL)
                        .platformTextInput()
                        .platformURLKeyboard()
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .foregroundStyle(.green)
            }

            Button {
                Task {
                    guard let baseURL = resolvedBaseURL() else {
                        viewModel.errorMessage = "Invalid base URL."
                        return
                    }

                    let success = await viewModel.saveToken(baseURL: baseURL)
                    if success {
                        onAuthenticated()
                    }
                }
            } label: {
                if viewModel.isSaving {
                    ProgressView()
                } else {
                    Text("Save Token")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving)
        }
        .padding()
    }

    private func resolvedBaseURL() -> URL? {
        if !useEnterprise {
            enterpriseBaseURL = GitHubAPIClient.defaultBaseURL.absoluteString
        }
        return GitHubEndpoint.resolve(
            useEnterprise: useEnterprise,
            configuredBaseURL: enterpriseBaseURL
        )
    }
}

#Preview {
    AuthView(onAuthenticated: {})
}
