import Foundation
import OSLog
import NetworkCore

final class ServiceProvider: Sendable {
    static let shared = ServiceProvider()

    private init () {
    }

    let apiRequestManager: APIRequestManager = {
        let appConfiguration = AppConfiguration()

        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "Network")
        let requestBuilder = RijksAPIRequestBuilder(
            host: appConfiguration.apiBaseURL,
            apiKey: appConfiguration.apiKey,
            culture: .en,
            logger: logger
        )

        return APIRequestManager(networkService: NetworkService(), requestBuilder: requestBuilder)
    }()
}
