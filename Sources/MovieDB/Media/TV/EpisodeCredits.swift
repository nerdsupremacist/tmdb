
import Foundation
import GraphZahl

final class EpisodeCredits<Value: ConcreteResolvable & OutputResolvable>: GraphQLObject {
    static var concreteTypeName: String {
        return "EpisodeCreditsWith\(Value.concreteTypeName)"
    }

    @InlineAsInterface
    var base: Credits<Value>

    let guestStars: [CastCredit<Value>]

    init(base: Credits<Value>, guestStars: [CastCredit<Value>]) {
        self.base = base
        self.guestStars = guestStars
    }
}

extension EpisodeCredits: Decodable where Value: Decodable {
    private enum CodingKeys: String, CodingKey {
        case guestStars = "guest_stars"
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(base: try Credits(from: decoder),
                  guestStars: try container.decode([CastCredit<Value>].self, forKey: .guestStars))
    }
}

extension EpisodeCredits {

    func map<T: ConcreteResolvable & OutputResolvable>(_ transform: (Value) throws -> T) rethrows -> EpisodeCredits<T> {
        return EpisodeCredits<T>(base: try base.map(transform),
                                 guestStars: try guestStars.map { try $0.map(transform) })
    }

}
