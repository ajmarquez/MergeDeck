//
//  PRDetailView.swift
//  MergeDeck
//

import SwiftUI

struct PRDetailView: View {
    let pullRequest: PullRequest

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Repository", value: pullRequest.repository.fullName)
                LabeledContent("Pull Request", value: "#\(pullRequest.number)")
                LabeledContent("Status") {
                    HStack(spacing: 8) {
                        Image(systemName: pullRequest.ciStatus.icon)
                            .foregroundStyle(pullRequest.ciStatus.color)
                        Text(pullRequest.ciStatus.rawValue.capitalized)
                    }
                }
                LabeledContent("Updated") {
                    Text(pullRequest.updatedAt, format: .dateTime.month().day().hour().minute())
                }
                Link("Open in GitHub", destination: pullRequest.url)
            }

            Section("Checks") {
                if pullRequest.checkRuns.isEmpty {
                    Text("No check runs available")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pullRequest.checkRuns) { checkRun in
                        HStack(spacing: 8) {
                            Image(systemName: icon(for: checkRun))
                                .foregroundStyle(color(for: checkRun))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(checkRun.name)
                                Text(label(for: checkRun))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let detailsURL = checkRun.detailsURL {
                                Link(destination: detailsURL) {
                                    Image(systemName: "arrow.up.right.square")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("PR #\(pullRequest.number)")
    }

    private func label(for checkRun: CheckRun) -> String {
        if let conclusion = checkRun.conclusion {
            return conclusion.rawValue.capitalized
        }
        return checkRun.status.rawValue.capitalized
    }

    private func icon(for checkRun: CheckRun) -> String {
        if checkRun.status != .completed {
            return "clock.arrow.circlepath"
        }

        switch checkRun.conclusion {
        case .success:
            return "checkmark.circle.fill"
        case .failure:
            return "xmark.circle.fill"
        case .neutral:
            return "minus.circle.fill"
        case .cancelled, .skipped, .timedOut:
            return "exclamationmark.circle.fill"
        case nil:
            return "questionmark.circle"
        }
    }

    private func color(for checkRun: CheckRun) -> Color {
        if checkRun.status != .completed {
            return .yellow
        }

        switch checkRun.conclusion {
        case .success:
            return .green
        case .failure:
            return .red
        case .neutral:
            return .gray
        case .cancelled, .skipped, .timedOut:
            return .orange
        case nil:
            return .secondary
        }
    }
}
