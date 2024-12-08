import Foundation

struct RijksCollection: Codable {
    struct Facet: Codable {
        struct FacetItem: Codable {
            let key: String
            let value: Int
        }
        let facets: [FacetItem]
        let name: String
    }

    let artObjects: [RijkArtObject]
    let facets: [Facet]

    var techniques: [Facet.FacetItem] {
        facets.first(where: { $0.name == "technique" })?.facets ?? []
    }
}
