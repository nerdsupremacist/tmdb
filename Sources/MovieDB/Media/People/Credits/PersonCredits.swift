
import Foundation
import GraphZahl
import NIO

class PersonCredits: GraphQLObject {
    @Ignore
    var id: Int

    init(id: Int) {
        self.id = id
    }

    func all(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<MovieOrTV>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "combined_credits")
    }

    func movies(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<Movie>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "movie_credits")
    }

    func tv(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<TVShow>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "tv_credits")
    }
}
