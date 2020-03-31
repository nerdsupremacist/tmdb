
import Foundation

class DetailedSeason: Season {
    let episodes: [Episode]

    private enum CodingKeys: String, CodingKey {
        case episodes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        episodes = try container.decode([Episode].self, forKey: .episodes)
        try super.init(from: decoder)
    }
}
