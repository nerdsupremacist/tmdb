
import Foundation
import GraphZahl
import NIO

class TV: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "search", "tv", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "trending", "tv", .constant(timeWindow.rawValue))
    }

    func show(id: ID) -> EventLoopFuture<TVShow> {
        return id
            .idValue(for: .show, eventLoop: viewerContext.request.eventLoop)
            .flatMap { self.viewerContext.tmdb.show(id: $0) }
            .map { TVShow(details: $0, viewerContext: self.viewerContext) }
    }
    
    func season(id: ID) -> EventLoopFuture<Season> {
        return id.idValue(for: .season, eventLoop: viewerContext.request.eventLoop)
            .flatMap { (showId, seasonNumber) -> EventLoopFuture<Season> in
                return self.viewerContext.tmdb.show(id: showId).flatMap { $0.season(viewerContext: self.viewerContext, number: seasonNumber) }
            }
    }

    func network(id: ID) -> EventLoopFuture<Network> {
        return id.idValue(for: .network, eventLoop: viewerContext.request.eventLoop)
            .flatMap { id in
                return self.viewerContext.tmdb.network(id: id)
            }
    }

    func episode(id: ID) -> EventLoopFuture<Episode> {
        return id.idValue(for: .episode, eventLoop: viewerContext.request.eventLoop)
            .flatMap { (showId, seasonNumber, episodeNumber) -> EventLoopFuture<DetailedEpisode> in
                return self
                    .viewerContext
                    .tmdb
                    .show(id: showId)
                    .flatMap { show in
                        return self.viewerContext.episode(showId: showId, seasonNumber: seasonNumber, episodeNumber: episodeNumber, showName: show.name)
                    }
            }
            .map { Episode(details: $0, viewerContext: self.viewerContext) }
    }

    func upcoming() -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", "upcoming")
    }

    func topRated() -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", "top_rated")
    }

    func popular() -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", "popular")
    }

    func onTheAir() -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", "on_the_air")
    }

    func airingToday() -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", "airing_today")
    }
}
