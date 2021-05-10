
import Foundation
import NIO
import GraphZahl
import Vapor
import Cache
import ContextKit

class Season: GraphQLObject {
    @Inline
    var season: BasicSeason

    @LazyInline
    var details: DetailedSeason

    init(season: BasicSeason, viewerContext: MovieDB.ViewerContext) {
        self.season = season
        self._details = LazyInline { viewerContext.season(showId: season.showId, seasonNumber: season.data.seasonNumber, showName: season.showName) }
    }

    init(details: DetailedSeason, viewerContext: MovieDB.ViewerContext) {
        self.season = details.season
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
    }
}

extension Season: Node {

    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        let id = ID(season.showId, season.data.seasonNumber, for: .season)
        return eventLoop.future(id.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<Node?> {
        let viewerContext = context.anyViewerContext as! MovieDB.ViewerContext
        guard let newId = ID(id), newId.namespace == .season, newId.ids.count == 2 else { return eventLoop.future(nil) }
        return viewerContext
            .tmdb
            .show(id: newId.ids[0])
            .flatMap { $0.season(viewerContext: viewerContext, number: newId.ids[1]) }
            .map { $0 }
    }

}

extension MovieDB.ViewerContext {

    func season(showId: Int, seasonNumber: Int, showName: String) -> EventLoopFuture<DetailedSeason> {
        return tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(seasonNumber))).map { data in
            DetailedSeason(data: data, showName: showName, showId: showId)
        }
    }

}
