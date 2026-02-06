//
//  GitHubOAuthClient.swift
//  MergeDeck
//

import Foundation

actor GitHubOAuthClient {
    struct DeviceAuthorization {
        let deviceCode: String
        let userCode: String
        let verificationURI: URL
        let verificationURIComplete: URL?
        let expiresAt: Date
        let interval: Int
    }

    private let baseURL: URL
    private let clientID: String
    private let session: URLSession

    init(baseURL: URL, clientID: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.clientID = clientID
        self.session = session
    }

    func startDeviceAuthorization(scope: String = "repo read:user") async throws -> DeviceAuthorization {
        let endpoint = baseURL.appending(path: "/login/device/code")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = makeFormBody([
            "client_id": clientID,
            "scope": scope
        ])

        let (data, response) = try await session.data(for: request)
        try validate(response: response)

        let payload = try JSONDecoder().decode(DeviceCodeResponse.self, from: data)
        guard let verificationURI = URL(string: payload.verificationURI) else {
            throw APIError.oauthError("Invalid verification URL.")
        }

        let verificationURIComplete = payload.verificationURIComplete.flatMap(URL.init(string:))
        return DeviceAuthorization(
            deviceCode: payload.deviceCode,
            userCode: payload.userCode,
            verificationURI: verificationURI,
            verificationURIComplete: verificationURIComplete,
            expiresAt: .now.addingTimeInterval(TimeInterval(payload.expiresIn)),
            interval: max(payload.interval, 1)
        )
    }

    func pollForAccessToken(authorization: DeviceAuthorization) async throws -> String {
        while Date() < authorization.expiresAt {
            try await Task.sleep(nanoseconds: UInt64(authorization.interval) * 1_000_000_000)

            let endpoint = baseURL.appending(path: "/login/oauth/access_token")
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = makeFormBody([
                "client_id": clientID,
                "device_code": authorization.deviceCode,
                "grant_type": "urn:ietf:params:oauth:grant-type:device_code"
            ])

            let (data, response) = try await session.data(for: request)
            try validate(response: response)

            let tokenResponse = try JSONDecoder().decode(DeviceTokenResponse.self, from: data)
            if let token = tokenResponse.accessToken, !token.isEmpty {
                return token
            }

            switch tokenResponse.error {
            case "authorization_pending":
                continue
            case "slow_down":
                try await Task.sleep(nanoseconds: 5_000_000_000)
                continue
            case .none:
                throw APIError.oauthError("OAuth token response did not include an access token.")
            default:
                throw APIError.oauthError(tokenResponse.errorDescription ?? tokenResponse.error ?? "OAuth authorization failed.")
            }
        }

        throw APIError.oauthError("OAuth authorization timed out. Please try again.")
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    private func makeFormBody(_ values: [String: String]) -> Data {
        let query = values.map { key, value in
            let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        return Data(query.utf8)
    }
}

private extension GitHubOAuthClient {
    struct DeviceCodeResponse: Decodable {
        let deviceCode: String
        let userCode: String
        let verificationURI: String
        let verificationURIComplete: String?
        let expiresIn: Int
        let interval: Int

        enum CodingKeys: String, CodingKey {
            case deviceCode = "device_code"
            case userCode = "user_code"
            case verificationURI = "verification_uri"
            case verificationURIComplete = "verification_uri_complete"
            case expiresIn = "expires_in"
            case interval
        }
    }

    struct DeviceTokenResponse: Decodable {
        let accessToken: String?
        let error: String?
        let errorDescription: String?

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case error
            case errorDescription = "error_description"
        }
    }
}
