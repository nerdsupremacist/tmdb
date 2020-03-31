
import Foundation
import GraphZahl

class Credits<Value: Decodable & ConcreteResolvable & OutputResolvable>: Decodable, GraphQLObject {
    static var concreteTypeName: String {
        return String(describing: Self.self).replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "")
    }

    let id: Int
    let cast: [CastCredit<Value>]
    let crew: [CrewCredit<Value>]
}
