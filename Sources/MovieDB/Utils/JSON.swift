
import Foundation

public enum JSON: Hashable, Encodable {
    case dictionary([String : JSON])
    case array([JSON])
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case null

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .dictionary(let dictionary):
            try dictionary.encode(to: encoder)
        case .array(let array):
            try array.encode(to: encoder)
        case .int(let int):
            try int.encode(to: encoder)
        case .double(let double):
            try double.encode(to: encoder)
        case .string(let string):
            try string.encode(to: encoder)
        case .bool(let bool):
            try bool.encode(to: encoder)
        case .null:
            try Optional<Int>.none.encode(to: encoder)
        }
    }
}
