import OSLog
import NetworkCore

enum RijksRequestCulture: String {
    // swiftlint:disable:next identifier_name
    case en
    // swiftlint:disable:next identifier_name
    case nl
}

public class RijksAPIRequestBuilder: APIRequestBuilderProtocol {
    private let apiRequestBuilder: APIRequestBuilder

    init(host: URL, apiKey: String, culture: RijksRequestCulture, logger: Logger? = nil) {
        let host = host
            .appending(path: culture.rawValue)
            .appending(queryItems: [.init(name: "key", value: apiKey)])

        self.apiRequestBuilder = APIRequestBuilder(host: host, logger: logger)
    }

    public func createRequest(with apiRequest: APIRequest) throws -> URLRequest {
        try apiRequestBuilder.createRequest(with: apiRequest)
    }
}
