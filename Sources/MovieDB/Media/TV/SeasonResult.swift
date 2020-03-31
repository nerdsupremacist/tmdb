
import Foundation

class SeasonResult: Season {
    let episodeCount: Int

    private enum CodingKeys: String, CodingKey {
        case episodeCount = "episode_count"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        episodeCount = try container.decode(Int.self, forKey: .episodeCount)
        try super.init(from: decoder)
    }
}
