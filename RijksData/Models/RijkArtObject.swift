import Foundation

struct RijkArtObject: Codable {
    struct WebImage: Codable {
        let url: URL?
    }

    let objectNumber: String
    let title: String
    let webImage: WebImage?
    let headerImage: WebImage
}
