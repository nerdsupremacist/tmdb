
import Foundation

class PersonListResult: MediumPerson {
    let knownFor: [MovieOrTV<DecodableTypeNamespace>]

    private enum CodingKeys: String, CodingKey {
        case knownFor = "known_for"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        knownFor = try container.decode([MovieOrTV<DecodableTypeNamespace>].self, forKey: .knownFor)
        try super.init(from: decoder)
    }
}
