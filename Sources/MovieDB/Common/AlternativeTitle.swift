
import Foundation
import GraphZahl

class AlternativeTitle: Decodable, GraphQLObject {
    let iso3166_1, title, type: String

    private enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case title, type
    }
}

class AlternativeTitles: Decodable, GraphQLObject {
    let titles: [AlternativeTitle]
}
