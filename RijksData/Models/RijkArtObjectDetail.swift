import Foundation

struct RijkArtObjectDetailResult: Codable {
    let artObject: RijkArtObjectDetail
}

struct RijkArtObjectLabel: Codable {
    let description: String?
}

struct RijkArtObjectDetail: Codable {
    let objectNumber: String
    let title: String?
    let label: RijkArtObjectLabel
    let webImage: RijkArtObject.WebImage?

    lazy var id: RijkArtObject.ID = RijkArtObject.ID(value: objectNumber)
}
