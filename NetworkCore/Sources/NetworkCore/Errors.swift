import Foundation

enum APIError: Error {
    case undefinedError
    case serverError(statusCode: Int)
    case decodeError(error: Error)
}

enum NetworkError: Error {
    case invalidHTTPResponse
    case networkFailure(error: Error)
}
