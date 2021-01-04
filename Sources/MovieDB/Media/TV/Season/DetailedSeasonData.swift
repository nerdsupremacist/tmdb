
import Foundation

class DetailedSeasonData: SeasonData {
    let episodes: [EpisodeData]

    private enum CodingKeys: String, CodingKey {
        case episodes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        episodes = try container.decode([EpisodeData].self, forKey: .episodes)
        try super.init(from: decoder)
    }
}
