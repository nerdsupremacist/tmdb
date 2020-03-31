
import Foundation
import GraphZahl

class EpisodeCredits<Value: Decodable & ConcreteResolvable & OutputResolvable>: Credits<Value> {
    let guestStars: [CastCredit<Value>]

    private enum CodingKeys: String, CodingKey {
        case guestStars = "guest_stars"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guestStars = try container.decode([CastCredit<Value>].self, forKey: .guestStars)
        try super.init(from: decoder)
    }
}
