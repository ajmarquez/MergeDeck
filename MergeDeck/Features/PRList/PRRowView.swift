//
//  PRRowView.swift
//  MergeDeck
//

import SwiftUI

struct PRRowView: View {
    let pullRequest: PullRequest

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: pullRequest.ciStatus.icon)
                .foregroundStyle(pullRequest.ciStatus.color)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("#\(pullRequest.number)")
                        .foregroundStyle(.secondary)
                    if pullRequest.isDraft {
                        Text("DRAFT")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.gray.opacity(0.2), in: Capsule())
                    }
                }

                Text(pullRequest.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(pullRequest.repository.fullName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !pullRequest.failedChecks.isEmpty {
                    Text("Failing: \(pullRequest.failedChecks.map { $0.name }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}
