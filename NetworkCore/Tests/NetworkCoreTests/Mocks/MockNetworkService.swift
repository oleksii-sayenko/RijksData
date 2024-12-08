import Foundation
@testable import NetworkCore

final class MockNetworkService: NetworkServiceProtocol {
    var mockResult: (Data, URLResponse)?
    var mockError: Error?

    func load(using request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return mockResult!
    }
}
