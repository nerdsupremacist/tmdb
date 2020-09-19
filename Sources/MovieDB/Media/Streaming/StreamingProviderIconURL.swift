
import Foundation
import NIO
import GraphZahl
import GraphQL
import ContextKit

struct StreamingProviderIconURL: Decodable, DelegatedOutputResolvable {
    let path: String

    init(from decoder: Decoder) throws {
        self.path = try String(from: decoder)
    }

    func url(viewerContext: MovieDB.ViewerContext) -> URL {
        return viewerContext.justWatchImageBase.appendingPathComponent(path.replacingOccurrences(of: "{profile}", with: "s100"))
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        return url(viewerContext: context.anyViewerContext as! MovieDB.ViewerContext)
    }
}
