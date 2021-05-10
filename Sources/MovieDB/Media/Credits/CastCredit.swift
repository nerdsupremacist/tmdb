
import Foundation
import GraphZahl

final class CastCredit<Value: ConcreteResolvable & OutputResolvable>: GraphQLObject {
    static var concreteTypeName: String {
        return "CastCreditWith\(Value.concreteTypeName)"
    }

    @InlineAsInterface
    var base: BaseCredit<Value>

    let character: String

    init(base: BaseCredit<Value>, character: String) {
        self.base = base
        self.character = character
    }
}

extension CastCredit: Decodable where Value: Decodable {
    private enum CodingKeys: String, CodingKey {
        case character
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(base: try BaseCredit(from: decoder),
                  character: try container.decode(String.self, forKey: .character))
    }
}

extension CastCredit {

    func map<T : ConcreteResolvable & OutputResolvable>(_ transform: (Value) throws -> T) rethrows -> CastCredit<T> {
        return CastCredit<T>(base: try base.map(transform), character: character)
    }

}
