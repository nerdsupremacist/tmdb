
import Foundation
import GraphZahl
import NIO

class Person: BasicPerson {
    let isAdult: Bool
    let popularityIndex: Double

    private enum CodingKeys: String, CodingKey {
        case isAdult = "adult"
        case popularityIndex = "popularity"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isAdult = try container.decode(Bool.self, forKey: .isAdult)
        popularityIndex = try container.decode(Double.self, forKey: .popularityIndex)
        try super.init(from: decoder)
    }
}
