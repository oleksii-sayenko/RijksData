import Foundation
@testable import NetworkCore

struct MockAPIRequest: APIRequest {
    var path: String
    var method: APIRequestMethod
    var headers: [String: String]?
    var bodyParams: Codable?
    var urlParams: [String: Any]?
}

