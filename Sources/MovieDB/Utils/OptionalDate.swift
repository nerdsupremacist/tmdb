
import Foundation
import GraphQL
import GraphZahl
import ContextKit
import NIO

@propertyWrapper
struct OptionalDate {
    var wrappedValue: Date?
}

extension OptionalDate: Decodable {

    static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    init(from decoder: Decoder) throws {
        let string = try String(from: decoder)
        switch string {
        case "":
            self.wrappedValue = nil
            break
        default:
            guard let date = OptionalDate.formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string \(string) is not in a supported format."))
            }
            self.wrappedValue = date
        }
    }

}

extension OptionalDate: DelegatedOutputResolvable {

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        return wrappedValue
    }

}
