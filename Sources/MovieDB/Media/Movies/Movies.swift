
import Foundation
import GraphZahl
import NIO

class Movies: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<Movie.Connection>  {
        return viewerContext.movies(at: "search", "movie", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "trending", "movie", .constant(timeWindow.rawValue))
    }

    func movie(id: ID) -> EventLoopFuture<Movie> {
        return id
            .idValue(for: .movie, eventLoop: viewerContext.request.eventLoop)
            .flatMap { self.viewerContext.tmdb.movie(id: $0) }
            .map { Movie(details: $0, viewerContext: self.viewerContext) }
    }

    func productionCompany(id: ID) -> EventLoopFuture<ProductionCompany> {
        return id
            .idValue(for: .productionCompany, eventLoop: viewerContext.request.eventLoop)
            .flatMap { id in
                return self.viewerContext.tmdb.productionCompany(id: id)
            }
    }

    func upcoming() -> EventLoopFuture<AnyFixedPageSizeIndexedConnection<Movie>> {
        return viewerContext.movies(at: "movie", "upcoming")
    }

    func topRated() -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "movie", "top_rated")
    }

    func popular() -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "movie", "popular")
    }

    func nowPlaying() -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "movie", "now_playing")
    }
}
