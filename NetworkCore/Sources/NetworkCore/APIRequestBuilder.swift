import Foundation
@preconcurrency import OSLog

public protocol APIRequestBuilderProtocol: Sendable {
    func createRequest(with apiRequest: APIRequest) throws -> URLRequest
}

public final class APIRequestBuilder: APIRequestBuilderProtocol {
    private let host: URL
    private let logger: Logger?

    public init(host: URL, logger: Logger? = nil) {
        self.host = host
        self.logger = logger
    }

    public func createRequest(with apiRequest: APIRequest) throws -> URLRequest {
        let url = host.appendingPathComponent(apiRequest.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = apiRequest.method.rawValue
        urlRequest.allHTTPHeaderFields = apiRequest.headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            logger?.critical("can't resolve \(url.absoluteString) into componets")
            throw URLError(.badURL)
        }

        let queryItems = apiRequest.urlParams?.compactMap {
            URLQueryItem(name: $0, value: "\($1)")
        }

        if let queryItems {
            components.queryItems = (components.queryItems ?? []) + queryItems
        }

        urlRequest.url = components.url

        if let bodyParams = apiRequest.bodyParams {
            urlRequest.httpBody = try JSONEncoder().encode(bodyParams)
        }

        return urlRequest
    }
}
