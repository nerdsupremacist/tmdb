
import Foundation
import GraphZahl

class Credits<Value: Decodable & ConcreteResolvable & OutputResolvable>: Decodable, GraphQLObject {
    static var concreteTypeName: String {
        return "\(Value.concreteTypeName)Credits"
    }

    let id: Int
    let cast: [CastCredit<Value>]
    let crew: [CrewCredit<Value>]
}
