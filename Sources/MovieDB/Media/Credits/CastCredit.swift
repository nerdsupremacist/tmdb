
import Foundation
import GraphZahl

class CastCredit<Value: Decodable & ConcreteResolvable & OutputResolvable>: BaseCredit<Value> {
    let character: String

    private enum CodingKeys: String, CodingKey {
        case character
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        character = try container.decode(String.self, forKey: .character)
        try super.init(from: decoder)
    }
}
