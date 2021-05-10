
import Foundation
import GraphZahl

class DetailedEpisodeData: EpisodeData {
    @Ignore
    var internalCrew: [CrewCredit<BasicPerson>]

    @Ignore
    var internalGuestStars: [CastCredit<BasicPerson>]

    private enum CodingKeys: String, CodingKey {
        case crew
        case guestStars = "guest_stars"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        internalCrew = try container.decode([CrewCredit<BasicPerson>].self, forKey: .crew)
        internalGuestStars = try container.decode([CastCredit<BasicPerson>].self, forKey: .guestStars)
        try super.init(from: decoder)
    }

    func crew(viewerContext: MovieDB.ViewerContext) -> [CrewCredit<Person>] {
        return internalCrew.map { $0.map { Person(person: $0, viewerContext: viewerContext) } }
    }

    func guestStars(viewerContext: MovieDB.ViewerContext) -> [CastCredit<Person>] {
        return internalGuestStars.map { $0.map { Person(person: $0, viewerContext: viewerContext) } }
    }
}
