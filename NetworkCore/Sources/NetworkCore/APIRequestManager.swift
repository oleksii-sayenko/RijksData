import Foundation
import OSLog

public protocol APIRequestManagerProtocol: Sendable {
    func perform<T: Decodable>(_ request: APIRequest) async throws -> T
}

public extension APIRequestManagerProtocol {
    func perform<T: Decodable>(_ request: APIRequest) async throws -> T {
        try await perform(request)
    }
}

public class APIRequestManager: APIRequestManagerProtocol {
    private let networkService: NetworkServiceProtocol
    private let requestBuilder: APIRequestBuilderProtocol
    private let logger: Logger?

    public init(
        networkService: NetworkServiceProtocol,
        requestBuilder: APIRequestBuilderProtocol,
        logger: Logger? = nil
    ) {
        self.networkService = networkService
        self.requestBuilder = requestBuilder
        self.logger = logger
    }

    public func perform<T: Decodable>(_ request: APIRequest) async throws -> T {
        try await run(request)
    }

    private func run<T: Decodable>(_ request: APIRequest) async throws -> T {
        let urlRequest = try requestBuilder.createRequest(with: request)
        do {
            let (data, response) = try await networkService.load(using: urlRequest)
            return try handleResponse(data: data, response: response)
        } catch {
            logger?.critical("can't get data for URLRequest: \(urlRequest); error: \(error)")
            throw NetworkError.networkFailure(error: error)
        }
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        let response = try validateNetworkResponse(response)
        try validateResponseCode(response)

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger?.critical("can't decode response to type: \(T.self); error: \(error)")
            throw APIError.decodeError(error: error)
        }
    }

    private func validateNetworkResponse(_ response: URLResponse) throws -> HTTPURLResponse {
        guard let response = response as? HTTPURLResponse else {
            logger?.critical("can't resolve cast URLResponse to HTTPURLResponse: \(response)")
            throw NetworkError.invalidHTTPResponse
        }

        return response
    }

    private func validateResponseCode(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
            // swiftlint:disable:next no_magic_numbers
        case 200...299:
            break
        default:
            throw APIError.serverError(statusCode: response.statusCode)
        }
    }
}
