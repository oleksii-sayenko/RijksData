import XCTest
@testable import NetworkCore

class APIRequestManagerTests: XCTestCase {
    var SUT: APIRequestManager!
    var mockNetworkService: MockNetworkService!
    var mockRequestBuilder: MockRequestBuilder!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockRequestBuilder = MockRequestBuilder()
        SUT = APIRequestManager(
            networkService: mockNetworkService,
            requestBuilder: mockRequestBuilder,
            logger: nil
        )
    }

    override func tearDown() {
        SUT = nil
        mockNetworkService = nil
        mockRequestBuilder = nil
        super.tearDown()
    }

    func test_performRequest_success() async {
        // Given
        let expectedData = try! JSONEncoder().encode(["key": "value"])
        let expectedResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockNetworkService.mockResult = (expectedData, expectedResponse)
        let request = MockAPIRequest(path: "/path", method: .get)

        // When
        do {
            let data: [String: String] = try await SUT.perform(request)
            // Then
            XCTAssertEqual(data, ["key": "value"])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_performRequest_failure() async {
        // Given
        mockNetworkService.mockError = NetworkError.networkFailure(error: NSError(domain: "", code: 0, userInfo: nil))
        let request = MockAPIRequest(path: "/path", method: .get)

        // When
        do {
            let _: [String: String] = try await SUT.perform(request)
            XCTFail("Expected failure did not occur")
        } catch NetworkError.networkFailure {
            // Then
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
