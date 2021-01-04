
import Foundation

class DetailedEpisodeData: EpisodeData {
    let crew: [CrewCredit<BasicPerson>]
    let guestStars: [CastCredit<BasicPerson>]

    private enum CodingKeys: String, CodingKey {
        case crew
        case guestStars = "guest_stars"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        crew = try container.decode([CrewCredit<BasicPerson>].self, forKey: .crew)
        guestStars = try container.decode([CastCredit<BasicPerson>].self, forKey: .guestStars)
        try super.init(from: decoder)
    }
}
