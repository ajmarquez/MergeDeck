//
//  AuthView.swift
//  MergeDeck
//

import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @AppStorage("useEnterprise") private var useEnterprise = false
    @AppStorage("githubBaseURL") private var enterpriseBaseURL = ""
    @Environment(\.openURL) private var openURL

    let onAuthenticated: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("MergeDeck")
                    .font(.largeTitle)
                Text("Connect to GitHub")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Picker("Authentication", selection: $viewModel.authMode) {
                    ForEach(AuthViewModel.AuthMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.authMode == .oauth {
                    TextField("OAuth App Client ID", text: $viewModel.oauthClientID)
                        .platformTextInput()
                } else {
                    SecureField("Personal Access Token", text: $viewModel.token)
                        .platformTextInput()
                }

                Toggle("Use GitHub Enterprise", isOn: $useEnterprise)

                if useEnterprise {
                    TextField("https://github.company.com", text: $enterpriseBaseURL)
                        .platformTextInput()
                        .platformURLKeyboard()
                }
            }

            if viewModel.authMode == .oauth {
                VStack(alignment: .leading, spacing: 6) {
                    Text("OAuth uses GitHub Device Flow.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let code = viewModel.oauthUserCode {
                        Text("Code: \(code)")
                            .font(.headline)
                    }
                    if let verificationURL = viewModel.oauthVerificationURL {
                        Button("Open Verification URL") {
                            openURL(verificationURL)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    let success: Bool
                    if viewModel.authMode == .oauth {
                        guard let oauthBaseURL = resolvedOAuthBaseURL() else {
                            viewModel.errorMessage = "Invalid OAuth base URL."
                            return
                        }
                        success = await viewModel.startOAuth(baseURL: baseURL, oauthBaseURL: oauthBaseURL)
                    } else {
                        success = await viewModel.saveToken(baseURL: baseURL)
                    }
                    if success {
                        onAuthenticated()
                    }
                }
            } label: {
                if viewModel.isSaving || viewModel.isAuthorizingOAuth {
                    ProgressView()
                } else {
                    Text(viewModel.authMode == .oauth ? "Start OAuth" : "Save Token")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isSaving || viewModel.isAuthorizingOAuth)
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

    private func resolvedOAuthBaseURL() -> URL? {
        if !useEnterprise {
            return GitHubEndpoint.defaultOAuthBaseURL
        }
        return GitHubEndpoint.resolveOAuthBase(
            useEnterprise: true,
            configuredBaseURL: enterpriseBaseURL
        )
    }
}

#Preview {
    AuthView(onAuthenticated: {})
}
