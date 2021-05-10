
import Foundation
import GraphZahl
import NIO

class Keyword: Decodable, GraphQLObject {
    let id: Int
    let name: String

    func movies(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "keyword", .constant(String(id)), "movies")
    }
}

class Keywords: Decodable {
    let keywords: [Keyword]
}
