
import Foundation
import GraphZahl

enum Gender: String, CaseIterable, GraphQLEnum, Decodable {
    case unknownOrNonBinary
    case female
    case male

    init(from decoder: Decoder) throws {
        let value = try Int(from: decoder)

        guard Gender.allCases.indices.contains(value) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value \(value) is not convertible to Gender"))
        }

        self = Gender.allCases[value]
    }
}
