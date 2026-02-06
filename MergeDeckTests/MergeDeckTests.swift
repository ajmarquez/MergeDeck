//
//  MergeDeckTests.swift
//  MergeDeckTests
//
//  Created by Abelardo Jesus Marquez Gonzalez on 05.02.26.
//

import Foundation
import Testing
@testable import MergeDeck

struct MergeDeckTests {
    @Test
    func decodingPullRequests() throws {
        let data = Data(samplePullRequestJSON.utf8)
        let payload = try GitHubAPIClient.decodePullRequests(from: data)

        #expect(payload.viewerLogin == "octocat")
        #expect(payload.pullRequests.count == 1)

        let pr = payload.pullRequests[0]
        #expect(pr.number == 42)
        #expect(pr.repository.fullName == "octocat/Hello-World")
        #expect(pr.ciStatus == .failure)
        #expect(pr.failedChecks.count == 1)
    }

    @Test
    func apiClientBuildsAuthRequest() async throws {
        let tokenStore = InMemoryTokenStore(token: "test-token")
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        defer { MockURLProtocol.requestHandler = nil }

        MockURLProtocol.requestHandler = { request in
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

            let bodyData = try #require(requestBodyData(request))
            let bodyObject = try #require(try JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
            let query = bodyObject["query"] as? String
            #expect(query?.isEmpty == false)

            let response = HTTPURLResponse(
                url: request.url ?? URL(string: "https://example.com/graphql")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (response, Data(samplePullRequestJSON.utf8))
        }

        let client = GitHubAPIClient(
            baseURL: URL(string: "https://example.com/graphql")!,
            tokenStore: tokenStore,
            session: session
        )

        let prs = try await client.fetchMyPullRequests()
        #expect(prs.count == 1)
    }

    @Test
    func keychainRoundTrip() async throws {
        #if os(iOS)
        return
        #else
        let environment = ProcessInfo.processInfo.environment
        if environment["CI"] == "true"
            || environment["GITHUB_ACTIONS"] == "true"
            || environment["SIMULATOR_UDID"] != nil
        {
            return
        }

        let service = "com.mergedeck.test.\(UUID().uuidString)"
        let manager = KeychainManager(service: service)

        try await manager.setToken("token-value")
        let stored = await manager.getToken()
        #expect(stored == "token-value")

        try await manager.deleteToken()
        #endif
    }
}

private final class InMemoryTokenStore: TokenStore {
    private var token: String?

    init(token: String?) {
        self.token = token
    }

    func getToken() async -> String? {
        token
    }

    func setToken(_ token: String) async throws {
        self.token = token
    }

    func deleteToken() async throws {
        token = nil
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: APIError.invalidResponse)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func requestBodyData(_ request: URLRequest) -> Data? {
    if let body = request.httpBody {
        return body
    }

    guard let stream = request.httpBodyStream else {
        return nil
    }

    stream.open()
    defer { stream.close() }

    let bufferSize = 1024
    var data = Data()
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }

    while stream.hasBytesAvailable {
        let read = stream.read(buffer, maxLength: bufferSize)
        if read < 0 {
            return nil
        }
        if read == 0 {
            break
        }
        data.append(buffer, count: read)
    }

    return data
}

private let samplePullRequestJSON = """
{
  "data": {
    "viewer": {
      "login": "octocat",
      "pullRequests": {
        "nodes": [
          {
            "id": "PR_kwDOAA",
            "number": 42,
            "title": "Fix regression",
            "url": "https://github.com/octocat/Hello-World/pull/42",
            "isDraft": false,
            "createdAt": "2026-02-05T12:00:00Z",
            "updatedAt": "2026-02-05T13:00:00Z",
            "repository": {
              "name": "Hello-World",
              "owner": {
                "login": "octocat"
              }
            },
            "commits": {
              "nodes": [
                {
                  "commit": {
                    "statusCheckRollup": {
                      "state": "FAILURE",
                      "contexts": {
                        "nodes": [
                          {
                            "__typename": "CheckRun",
                            "id": "CR_1",
                            "name": "CI",
                            "status": "COMPLETED",
                            "conclusion": "FAILURE",
                            "detailsUrl": "https://github.com/checks/1"
                          },
                          {
                            "__typename": "StatusContext",
                            "id": "SC_1",
                            "context": "lint",
                            "state": "SUCCESS",
                            "targetUrl": "https://github.com/status/1"
                          }
                        ]
                      }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
"""
