
import Foundation
import GraphZahl

final class CrewCredit<Value: ConcreteResolvable & OutputResolvable>: GraphQLObject {
    static var concreteTypeName: String {
        return "CrewCreditWith\(Value.concreteTypeName)"
    }

    @InlineAsInterface
    var base: BaseCredit<Value>

    let department: String
    let job: String

    init(base: BaseCredit<Value>, department: String, job: String) {
        self.base = base
        self.department = department
        self.job = job
    }
}

extension CrewCredit: Decodable where Value: Decodable {

    private enum CodingKeys: String, CodingKey {
        case department
        case job
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(base: try BaseCredit(from: decoder),
                  department: try container.decode(String.self, forKey: .department),
                  job: try container.decode(String.self, forKey: .job))
    }

}

extension CrewCredit {

    func map<T : ConcreteResolvable & OutputResolvable>(_ transform: (Value) throws -> T) rethrows -> CrewCredit<T> {
        return CrewCredit<T>(base: try base.map(transform), department: department, job: job)
    }

}
