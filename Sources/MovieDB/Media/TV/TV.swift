
import Foundation
import GraphZahl
import NIO

class TV: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "search", "tv", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "trending", "tv", .constant(timeWindow.rawValue))
    }

    func show(id: ID) -> EventLoopFuture<DetailedTVShow> {
        return id
            .idValue(for: .show, eventLoop: viewerContext.request.eventLoop)
            .flatMap { self.viewerContext.tmdb.show(id: $0) }
    }

    func upcoming() -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "tv", "upcoming")
    }

    func topRated() -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "tv", "top_rated")
    }

    func popular() -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "tv", "popular")
    }

    func onTheAir() -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "tv", "on_the_air")
    }

    func airingToday() -> EventLoopFuture<Paging<TVShow>> {
        return viewerContext.tmdb.get(at: "tv", "airing_today")
    }
}
