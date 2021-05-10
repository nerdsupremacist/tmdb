
import Foundation
import GraphZahl

final class BaseCredit<Value: ConcreteResolvable & OutputResolvable>: GraphQLObject {
    static var concreteTypeName: String {
        return "CreditWith\(Value.concreteTypeName)"
    }

    let id: String
    let value: Value

    init(id: String, value: Value) {
        self.id = id
        self.value = value
    }
}

extension BaseCredit: Decodable where Value: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "credit_id"
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(id: try container.decode(String.self, forKey: .id), value: try Value(from: decoder))
    }
}

extension BaseCredit {

    func map<T : ConcreteResolvable & OutputResolvable>(_ transform: (Value) throws -> T) rethrows -> BaseCredit<T> {
        return BaseCredit<T>(id: id, value: try transform(value))
    }

}
