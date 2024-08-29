import Foundation
import NetworkCore

enum RijksAPIRequest: APIRequest {
    case collection( page: Int, pageSize: Int, involvedMaker: String, technique: String?)

    var path: String {
        switch self {
        case .collection:
            return "collection"
        }
    }

    var method: APIRequestMethod {
        switch self {
        case .collection:
            return .get
        }
    }

    var urlParams: [String: Any]? {
        switch self {
        case let .collection(page, pageSize, involvedMaker, technique):
            var params = ["p": page, "ps": pageSize, "involvedMaker": involvedMaker] as [String: Any]
            params["technique"] = technique
            return params
        }
    }
}
