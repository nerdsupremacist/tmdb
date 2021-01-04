
import Foundation
import GraphZahl
import NIO
import ContextKit

class EpisodeData: Decodable, GraphQLObject {
    let airDate: Date
    let episodeNumber, id: Int
    let name, overview, productionCode: String
    let seasonNumber: Int
    let still: Image<StillSize>?
    let voteAverage: Double
    let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case still = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
