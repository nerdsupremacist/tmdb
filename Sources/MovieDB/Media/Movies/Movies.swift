
import Foundation
import GraphZahl
import NIO

class Movies: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "search", "movie", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "trending", "movie", .constant(timeWindow.rawValue))
    }

    func movie(id: Int) -> EventLoopFuture<DetailedMovie> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)))
    }

    func upcoming() -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "movie", "upcoming")
    }

    func topRated() -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "movie", "top_rated")
    }

    func popular() -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "movie", "popular")
    }

    func nowPlaying() -> EventLoopFuture<Paging<Movie>> {
        return viewerContext.tmdb.get(at: "movie", "now_playing")
    }
}
