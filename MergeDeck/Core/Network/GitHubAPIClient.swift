//
//  GitHubAPIClient.swift
//  MergeDeck
//

import Foundation

actor GitHubAPIClient {
    static let defaultBaseURL = URL(string: "https://api.github.com/graphql")!

    private let session: URLSession
    private let baseURL: URL
    private let tokenStore: TokenStore

    init(
        baseURL: URL = GitHubAPIClient.defaultBaseURL,
        tokenStore: TokenStore = KeychainManager.shared,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.tokenStore = tokenStore
        self.session = session
    }

    func fetchMyPullRequests() async throws -> [PullRequest] {
        let request = try await makeRequest(query: GraphQLQueries.myPullRequests)
        let (data, response) = try await session.data(for: request)
        try validate(response: response)

        let payload = try Self.decodePullRequests(from: data)
        return payload.pullRequests
    }

    func fetchViewerLogin() async throws -> String {
        let request = try await makeRequest(query: GraphQLQueries.viewerLogin)
        let (data, response) = try await session.data(for: request)
        try validate(response: response)

        return try Self.decodeViewerLogin(from: data)
    }

    private func makeRequest(query: String) async throws -> URLRequest {
        guard let token = await tokenStore.getToken() else {
            throw APIError.notAuthenticated
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GraphQLRequestBody(query: query)
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.rateLimited
        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    static func decodePullRequests(from data: Data) throws -> PullRequestPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(GraphQLResponse<PullRequestResponse>.self, from: data)
        if let message = response.errors?.first?.message {
            throw APIError.graphQLError(message)
        }
        guard let payload = response.data else {
            throw APIError.decodingFailed
        }

        let pullRequests = payload.viewer.pullRequests.nodes?.compactMap { node in
            mapPullRequest(node)
        } ?? []

        return PullRequestPayload(viewerLogin: payload.viewer.login, pullRequests: pullRequests)
    }

    static func decodeViewerLogin(from data: Data) throws -> String {
        let decoder = JSONDecoder()
        let response = try decoder.decode(GraphQLResponse<ViewerLoginResponse>.self, from: data)
        if let message = response.errors?.first?.message {
            throw APIError.graphQLError(message)
        }
        guard let login = response.data?.viewer.login else {
            throw APIError.decodingFailed
        }
        return login
    }
}

extension GitHubAPIClient {
    struct PullRequestPayload {
        let viewerLogin: String
        let pullRequests: [PullRequest]
    }
}

private extension GitHubAPIClient {
    struct GraphQLRequestBody: Encodable {
        let query: String
    }

    struct GraphQLResponse<Payload: Decodable>: Decodable {
        let data: Payload?
        let errors: [GraphQLError]?
    }

    struct GraphQLError: Decodable {
        let message: String
    }

    struct PullRequestResponse: Decodable {
        let viewer: ViewerResponse
    }

    struct ViewerResponse: Decodable {
        let login: String
        let pullRequests: PullRequestConnection
    }

    struct ViewerLoginResponse: Decodable {
        let viewer: ViewerLogin
    }

    struct ViewerLogin: Decodable {
        let login: String
    }

    struct PullRequestConnection: Decodable {
        let nodes: [PullRequestNode]?
    }

    struct PullRequestNode: Decodable {
        let id: String
        let number: Int
        let title: String
        let url: URL
        let isDraft: Bool
        let createdAt: Date
        let updatedAt: Date
        let repository: RepositoryNode
        let commits: CommitConnection
    }

    struct RepositoryNode: Decodable {
        let name: String
        let owner: OwnerNode
    }

    struct OwnerNode: Decodable {
        let login: String
    }

    struct CommitConnection: Decodable {
        let nodes: [CommitNode]?
    }

    struct CommitNode: Decodable {
        let commit: CommitDetails
    }

    struct CommitDetails: Decodable {
        let statusCheckRollup: StatusCheckRollup?
    }

    struct StatusCheckRollup: Decodable {
        let state: String?
        let contexts: StatusContextConnection?
    }

    struct StatusContextConnection: Decodable {
        let nodes: [StatusContextNode]?
    }

    struct CheckRunNode: Decodable {
        let id: String
        let name: String
        let status: String
        let conclusion: String?
        let detailsUrl: URL?
    }

    struct StatusContextNodeData: Decodable {
        let id: String
        let context: String
        let state: String
        let targetUrl: URL?
    }

    enum StatusContextNode: Decodable {
        case checkRun(CheckRunNode)
        case statusContext(StatusContextNodeData)

        enum CodingKeys: String, CodingKey {
            case typeName = "__typename"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let typeName = try container.decode(String.self, forKey: .typeName)
            switch typeName {
            case "CheckRun":
                self = .checkRun(try CheckRunNode(from: decoder))
            case "StatusContext":
                self = .statusContext(try StatusContextNodeData(from: decoder))
            default:
                self = .statusContext(try StatusContextNodeData(from: decoder))
            }
        }
    }

    static func mapPullRequest(_ node: PullRequestNode) -> PullRequest? {
        let repository = Repository(
            name: node.repository.name,
            owner: node.repository.owner.login,
            fullName: "\(node.repository.owner.login)/\(node.repository.name)"
        )

        let rollup = node.commits.nodes?.first?.commit.statusCheckRollup
        let ciStatus = CIStatus(statusCheckState: rollup?.state)
        let checkRuns = mapCheckRuns(from: rollup?.contexts?.nodes)

        return PullRequest(
            id: node.id,
            number: node.number,
            title: node.title,
            url: node.url,
            repository: repository,
            createdAt: node.createdAt,
            updatedAt: node.updatedAt,
            isDraft: node.isDraft,
            ciStatus: ciStatus,
            checkRuns: checkRuns
        )
    }

    static func mapCheckRuns(from nodes: [StatusContextNode]?) -> [CheckRun] {
        guard let nodes else { return [] }
        return nodes.map { node in
            switch node {
            case .checkRun(let checkRun):
                return CheckRun(
                    id: checkRun.id,
                    name: checkRun.name,
                    status: mapCheckStatus(checkRun.status),
                    conclusion: mapCheckConclusion(checkRun.conclusion),
                    detailsURL: checkRun.detailsUrl
                )
            case .statusContext(let statusContext):
                let status = mapStatusContextStatus(statusContext.state)
                let conclusion = mapStatusContextConclusion(statusContext.state)
                return CheckRun(
                    id: statusContext.id,
                    name: statusContext.context,
                    status: status,
                    conclusion: conclusion,
                    detailsURL: statusContext.targetUrl
                )
            }
        }
    }

    static func mapCheckStatus(_ status: String) -> CheckStatus {
        switch status.uppercased() {
        case "QUEUED":
            return .queued
        case "IN_PROGRESS":
            return .inProgress
        case "COMPLETED":
            return .completed
        default:
            return .completed
        }
    }

    static func mapCheckConclusion(_ conclusion: String?) -> CheckConclusion? {
        switch conclusion?.uppercased() {
        case "SUCCESS":
            return .success
        case "FAILURE", "ERROR":
            return .failure
        case "NEUTRAL":
            return .neutral
        case "CANCELLED":
            return .cancelled
        case "SKIPPED":
            return .skipped
        case "TIMED_OUT":
            return .timedOut
        default:
            return nil
        }
    }

    static func mapStatusContextStatus(_ state: String) -> CheckStatus {
        switch state.uppercased() {
        case "PENDING", "EXPECTED":
            return .inProgress
        default:
            return .completed
        }
    }

    static func mapStatusContextConclusion(_ state: String) -> CheckConclusion? {
        switch state.uppercased() {
        case "SUCCESS":
            return .success
        case "FAILURE", "ERROR":
            return .failure
        case "NEUTRAL":
            return .neutral
        case "PENDING", "EXPECTED":
            return nil
        default:
            return nil
        }
    }
}
