
import Foundation

class PersonListResult: Person {
    let knownFor: [MovieOrTV]

    enum CodingKeys: String, CodingKey {
        case knownFor = "known_for"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        knownFor = try container.decode([MovieOrTV].self, forKey: .knownFor)
        try super.init(from: decoder)
    }
}
