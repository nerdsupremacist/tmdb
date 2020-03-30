
import Foundation
import GraphZahl

extension URL: GraphQLScalar {
    public init(scalar: ScalarValue) throws {
        // attempt to read a string and read a url from it
        guard let url = URL(string: try scalar.string()) else {
            throw Client.Error.failedDecoding
        }
        self = url
    }

    public func encodeScalar() throws -> ScalarValue {
        // delegate encoding to absolute string
        return try absoluteString.encodeScalar()
    }
}
