
import Foundation
import GraphZahl

class BaseCredit<Value: Decodable & ConcreteResolvable & OutputResolvable>: Decodable, GraphQLObject {
    static var concreteTypeName: String {
        return String(describing: Self.self).replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
    }

    let id: String
    let value: Value

    enum CodingKeys: String, CodingKey {
        case id = "credit_id"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try Value(from: decoder)
    }
}
