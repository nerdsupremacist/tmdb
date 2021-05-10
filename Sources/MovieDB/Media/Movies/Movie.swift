
import Foundation
import NIO
import GraphZahl
import Vapor
import Cache

class Movie: GraphQLObject, Node {
    @Inline
    var movie: BasicMovie

    @LazyInline
    var details: DetailedMovie

    init(movie: BasicMovie, viewerContext: MovieDB.ViewerContext) {
        self.movie = movie
        self._details = LazyInline { viewerContext.tmdb.movie(id: movie.id) }
    }

    init(details: DetailedMovie, viewerContext: MovieDB.ViewerContext) {
        self.movie = details
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
    }
}

extension Movie: TMDBNode {
    static let namespace: ID.Namespace = .movie

    var id: Int {
        return movie.id
    }

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.movie(id: id).map { Movie(details: $0, viewerContext: viewerContext) }
    }
}

extension Client {

    func movie(id: Int) -> EventLoopFuture<DetailedMovie> {
        return get(at: "movie", .constant(String(id)))
    }

}

extension Movie {
    typealias Connection = AnyFixedPageSizeIndexedConnection<Movie>
}

extension MovieDB.ViewerContext {
    func movies(at path: PathComponent..., query: [String : String] = [:], expiry: Expiry = .minutes(30)) -> EventLoopFuture<Movie.Connection> {
        return tmdb.get(at: path, query: query, expiry: expiry, type: Paging<BasicMovie>.self).map { paging in
            return paging.map { Movie(movie: $0, viewerContext: self) }
        }
    }
}
