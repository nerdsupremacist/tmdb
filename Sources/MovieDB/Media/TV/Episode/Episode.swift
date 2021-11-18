
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

    @InlineAsInterface
    var streamable: Streamable

    init(episode: BasicEpisode, viewerContext: MovieDB.ViewerContext) {
        self.episode = episode
        self._details = LazyInline { viewerContext.episode(showId: episode.showId, seasonNumber: episode.data.seasonNumber, episodeNumber: episode.data.episodeNumber, showName: episode.showName) }
        self.streamable = Streamable { $0.streampingOptionsForEpisode(showId: episode.showId,
                                                                      showName: episode.showName,
                                                                      seasonNumber: episode.data.seasonNumber,
                                                                      episodeNumber: episode.data.episodeNumber,
                                                                      locale: $1) }
    }

    init(details: DetailedEpisode, viewerContext: MovieDB.ViewerContext) {
        self.episode = details.episode
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
        self.streamable = Streamable { $0.streampingOptionsForEpisode(showId: details.episode.showId,
                                                                      showName: details.episode.showName,
                                                                      seasonNumber: details.episode.data.seasonNumber,
                                                                      episodeNumber: details.episode.data.episodeNumber,
                                                                      locale: $1) }
    }
}

extension Episode: Node {

    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        let id = ID(episode.showId, episode.data.seasonNumber, episode.data.episodeNumber, for: .episode)
        return eventLoop.future(id.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<Node?> {
        let viewerContext = context.anyViewerContext as! MovieDB.ViewerContext
        guard let newId = ID(id), newId.namespace == .episode else { return eventLoop.future(nil) }
        let ids = newId.intIds()
        guard newId.ids.count == 3 else { return eventLoop.future(nil) }
        return viewerContext
            .tmdb
            .show(id: ids[0])
            .flatMap { viewerContext.episode(showId: ids[0], seasonNumber: ids[1], episodeNumber: ids[2], showName: $0.name) }
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
