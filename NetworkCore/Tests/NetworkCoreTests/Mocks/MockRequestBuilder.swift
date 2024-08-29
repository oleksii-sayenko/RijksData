import Foundation
@testable import NetworkCore

final class MockRequestBuilder: APIRequestBuilderProtocol {
    func createRequest(with apiRequest: APIRequest) throws -> URLRequest {
        return URLRequest(url: URL(string: "https://test.com")!)
    }
}
