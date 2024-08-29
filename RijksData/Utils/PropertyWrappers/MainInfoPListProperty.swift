import Foundation

@propertyWrapper
public struct MainInfoPListProperty<T> {
    private let key: String

    public init(_ key: String) {
        self.key = key
    }

    public var wrappedValue: T {
        // swiftlint:disable:next force_cast
        Bundle.main.object(forInfoDictionaryKey: key) as! T
    }
}
