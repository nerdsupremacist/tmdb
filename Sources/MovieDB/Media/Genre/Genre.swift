
import Foundation
import Vapor
import NIO
import GraphZahl

class Genre: Codable, GraphQLObject {
    @Ignore
    var id: Int

    let name: String

    func discover(viewerContext: MovieDB.ViewerContext) -> Discover {
        return Discover(viewerContext: viewerContext, initialInput: DiscoverInput(genres: .init(include: [graphqlID])))
    }
}

extension Genre: TMDBNode {
    static let namespace: ID.Namespace = .genre

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.genre(id: id).map { $0 }
    }
}

extension Client {

    func genre(id: Int) -> EventLoopFuture<Genre> {
        return get(at: "genre", .constant(String(id)))
    }

}
