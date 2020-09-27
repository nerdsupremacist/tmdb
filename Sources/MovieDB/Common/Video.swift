
import Foundation
import GraphZahl

class Video: Decodable, GraphQLObject {
    let id, iso639_1, iso3166_1, key: String
    let name, site: String
    let size: Int
    let type: String

    private enum CodingKeys: String, CodingKey {
        case id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case key, name, site, size, type
    }

    func thumbnail() -> URL? {
        switch site {
        case "YouTube":
            return URL(string: "https://img.youtube.com/vi/\(key)/maxresdefault.jpg")
        default:
            return nil
        }
    }

    func links() -> StreamingLinks? {
        switch site {
        case "YouTube":
            return StreamingLinks(web: URL(string: "https://www.youtube.com/watch?v=\(key)")!,
                                  androidTV: URL(string: key),
                                  tvOS: URL(string: "youtube://watch/\(key)"),
                                  fireTV: nil)
        default:
            return nil
        }
    }
}

class Videos: Decodable {
    let results: [Video]
}
