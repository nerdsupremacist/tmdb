
import Foundation
import GraphZahl
import ContextKit
import NIO

class SeasonData: Decodable, GraphQLObject {
    let airDate: Date?
    let id: Int
    let name: String
    let overview: String?
    let poster: Image<PosterSize>?
    let seasonNumber: Int

    private enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case id, name, overview
        case poster = "poster_path"
        case seasonNumber = "season_number"
    }
}
