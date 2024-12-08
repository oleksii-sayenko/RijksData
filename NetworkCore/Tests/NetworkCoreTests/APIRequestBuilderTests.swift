import XCTest
@testable import NetworkCore

class APIRequestBuilderTests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var requestBuilder: APIRequestBuilder!
    // swiftlint:disable:next force_unwrapping
    let baseURL = URL(string: "https://api.example.com")!

    override func setUp() {
        super.setUp()
        requestBuilder = APIRequestBuilder(host: baseURL, logger: nil)
    }

    override func tearDown() {
        requestBuilder = nil
        super.tearDown()
    }

    func test_createRequest_withAllComponents() throws {
        // Given
        let apiRequest = MockAPIRequest(
            path: "/test",
            method: .get,
            headers: ["Authorization": "Bearer token"],
            bodyParams: nil,
            urlParams: ["query": "value"]
        )

        // When
        let urlRequest = try requestBuilder.createRequest(with: apiRequest)

        // Then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/test?query=value")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Authorization"], "Bearer token")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_createRequest_withPostAndBody() throws {
        // Given
        let apiRequest = MockAPIRequest(
            path: "/post",
            method: .post,
            headers: nil,
            bodyParams: ["key": "value"],
            urlParams: nil
        )

        // When
        let urlRequest = try requestBuilder.createRequest(with: apiRequest)

        // Then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/post")
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertNotNil(urlRequest.httpBody)
    }
}
