import Foundation

public protocol APIRequest {
    var path: String { get }
    var method: APIRequestMethod { get }
    var headers: [String: String]? { get }
    var bodyParams: Codable? { get }
    var urlParams: [String: Any]? { get }
}

public enum APIRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public extension APIRequest {
    var headers: [String: String]? {
        nil
    }

    var bodyParams: Codable? {
        nil
    }

    var urlParams: [String: Any]? {
        nil
    }
}
