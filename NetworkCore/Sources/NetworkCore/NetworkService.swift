import Foundation

public protocol NetworkServiceProtocol {
    func load(using request: URLRequest) async throws -> (Data, URLResponse)
}

public final class NetworkService: NetworkServiceProtocol {
    private let urlSession: URLSession

    public init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    public func load(using request: URLRequest) async throws -> (Data, URLResponse) {
        try await urlSession.data(for: request)
    }
}
