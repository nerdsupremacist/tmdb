
import Foundation
import GraphZahl

final class Credits<Value: ConcreteResolvable & OutputResolvable>: GraphQLObject {
    static var concreteTypeName: String {
        return "CreditsWith\(Value.concreteTypeName)"
    }

    let id: Int
    let cast: [CastCredit<Value>]
    let crew: [CrewCredit<Value>]

    init(id: Int, cast: [CastCredit<Value>], crew: [CrewCredit<Value>]) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }
}

extension Credits: Decodable where Value: Decodable {

    enum CodingKeys: String, CodingKey {
        case id, cast, crew
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(id: try container.decode(Int.self, forKey: .id),
                  cast: try container.decode([CastCredit<Value>].self, forKey: .cast),
                  crew: try container.decode([CrewCredit<Value>].self, forKey: .crew))
    }

}

extension Credits {

    func map<T: ConcreteResolvable & OutputResolvable>(_ transform: (Value) throws -> T) rethrows -> Credits<T> {
        return Credits<T>(id: id,
                          cast: try cast.map { try $0.map(transform) },
                          crew: try crew.map { try $0.map(transform) })
    }

}
