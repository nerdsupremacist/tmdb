
import Foundation
import GraphZahl
import NIO

class Keyword: Decodable, GraphQLObject {
    @Ignore
    var id: Int

    let name: String

    var movies: NestedMovies {
        return .keyword(id: id)
    }

    var tv: NestedTV {
        return .keyword(id: id)
    }
}

extension Keyword: TMDBNode {

    static let namespace: ID.Namespace = .keyword

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.keyword(id: id).map { $0 }
    }

}

extension Client {

    func keyword(id: Int) -> EventLoopFuture<Keyword> {
        return get(at: "keyword", .constant(String(id)))
    }

}

class Keywords: Decodable {
    let keywords: [Keyword]
}
