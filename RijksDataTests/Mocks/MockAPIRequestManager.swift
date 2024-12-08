@testable import NetworkCore

final class MockAPIRequestManager: APIRequestManagerProtocol {
    var result: Any?
    var error: Error?

    func perform<T>(_ request: APIRequest) async throws -> T where T : Decodable {
        if let error = error {
            throw error
        }
        guard let result = result as? T else {
            fatalError("MockAPIRequestManager was not setup correctly. Expected result of type \(T.self)")
        }
        return result
    }
}
