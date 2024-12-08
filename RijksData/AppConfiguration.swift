import Foundation

private enum ConfigurationKeys {
    static let apiBaseURL = "APIBaseURL"
    static let apiKey = "APIKey"
}

final class AppConfiguration {
    @MainInfoPListProperty(ConfigurationKeys.apiBaseURL)
    var apiBaseURLString: String

    @MainInfoPListProperty(ConfigurationKeys.apiKey)
    var apiKey: String

    public var apiBaseURL: URL {
        guard let url = URL(string: apiBaseURLString) else {
            preconditionFailure("Wrong APIBaseURL")
        }
        return url
    }
}
