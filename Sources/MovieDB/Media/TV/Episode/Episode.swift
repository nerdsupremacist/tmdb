
import Foundation
import NIO
import GraphZahl
import Vapor
import Cache
import ContextKit

class Episode: GraphQLObject {
    @Inline
    var episode: BasicEpisode

    @LazyInline
    var details: DetailedEpisode

    init(episode: BasicEpisode, viewerContext: MovieDB.ViewerContext) {
        self.episode = episode
        self._details = LazyInline { viewerContext.episode(showId: episode.showId, seasonNumber: episode.data.seasonNumber, episodeNumber: episode.data.episodeNumber, showName: episode.showName) }
    }

    init(details: DetailedEpisode, viewerContext: MovieDB.ViewerContext) {
        self.episode = details.episode
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
    }
}

extension Episode: Node {

    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        let id = ID(episode.showId, episode.data.seasonNumber, episode.data.episodeNumber, for: .episode)
        return eventLoop.future(id.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<Node?> {
        let viewerContext = context.anyViewerContext as! MovieDB.ViewerContext
        guard let newId = ID(id), newId.namespace == .episode, newId.ids.count == 3 else { return eventLoop.future(nil) }
        return viewerContext
            .tmdb
            .show(id: newId.ids[0])
            .flatMap { viewerContext.episode(showId: newId.ids[0], seasonNumber: newId.ids[1], episodeNumber: newId.ids[2], showName: $0.name) }
            .map { Episode(details: $0, viewerContext: viewerContext) }
    }

}

extension MovieDB.ViewerContext {

    func episode(showId: Int, seasonNumber: Int, episodeNumber: Int, showName: String) -> EventLoopFuture<DetailedEpisode> {
        return tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber))).map { data in
            DetailedEpisode(data: data, showName: showName, showId: showId)
        }
    }

}
