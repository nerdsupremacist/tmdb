
import Foundation
import GraphZahl
import NIO
import ContextKit
import GraphQL

class StreamingCountry: GraphQLObject, Decodable {
    enum CodingKeys: String, CodingKey {
        case locale = "full_locale"
        case name = "country"
        case iso3166_2 = "iso_3166_2"
    }

    @Ignore
    var locale: String

    let name: String
    let iso3166_2: String

    func emoji() -> String {
        return iso3166_2.uppercased().unicodeScalars.reduce("") { result, item in
            guard let scalar = UnicodeScalar(127397 + item.value) else {
                return result
            }
            return result + String(scalar)
        }
    }
}

extension StreamingCountry: GraphZahl.Node {
    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        let id = ID(namespace: .streamingCountry, ids: [locale])
        return eventLoop.future(id.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<GraphZahl.Node?> {
        guard let newId = ID(id), newId.ids.count == 1 else { return eventLoop.future(nil) }
        let viewerContext = context.anyViewerContext as! MovieDB.ViewerContext
        let locale = newId.ids[0]
        return viewerContext.countries().map { $0.first { $0.locale.lowercased() == locale } }
    }
}
