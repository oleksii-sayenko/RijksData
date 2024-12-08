import Foundation
import NetworkCore

enum RijksAPIRequest: APIRequest {
    case collection( page: Int, pageSize: Int, involvedMaker: String, technique: String?)
    case detail(id: RijkArtObject.ID)

    var path: String {
        switch self {
        case .collection:
            return "collection"
        case .detail(let id):
            return "collection/\(id.value)"
        }
    }

    var method: APIRequestMethod {
        switch self {
        case .collection,
                .detail:
            return .get
        }
    }

    var urlParams: [String: Any]? {
        switch self {
        case let .collection(page, pageSize, involvedMaker, technique):
            var params = ["p": page, "ps": pageSize, "involvedMaker": involvedMaker] as [String: Any]
            params["technique"] = technique
            return params
        case .detail:
            return nil
        }
    }
}
