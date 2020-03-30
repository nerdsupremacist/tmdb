
import Foundation
import GraphZahl

class CrewCredit<Value: Decodable & ConcreteResolvable & OutputResolvable>: BaseCredit<Value> {
    let department: String
    let job: String

    private enum CodingKeys: String, CodingKey {
        case department
        case job
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        department = try container.decode(String.self, forKey: .department)
        job = try container.decode(String.self, forKey: .job)
        try super.init(from: decoder)
    }
}
