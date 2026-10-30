import Foundation

struct CatalogItem: Identifiable, Codable, Hashable {
    var id: String { streamURL.absoluteString }
    let name: String
    let streamURL: URL
    let category: String
    let logoURL: URL?
}
