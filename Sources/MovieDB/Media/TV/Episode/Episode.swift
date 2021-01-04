
import Foundation
import GraphZahl
import NIO

class Episode: GraphQLObject {
    @Inline
    var data: EpisodeData

    @Ignore
    var showName: String

    @Ignore
    var showId: Int

    init(data: EpisodeData, showName: String, showId: Int) {
        self.data = data
        self.showName = showName
        self.showId = showId
    }

    func streamingOptions(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[StreamingOption]?> {
        return viewerContext.streampingOptionsForEpisode(showId: showId, showName: showName, seasonNumber: data.seasonNumber, episodeNumber: data.episodeNumber)
    }

    func details(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<DetailedEpisode> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber))).map { data in
            DetailedEpisode(data: data, showName: self.showName, showId: self.showId)
        }
    }

    func externalIds(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<ExternalIDS> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber)), "external_ids")
    }

    func translations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<EpisodeImages> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber)), "images")
    }

    func videos(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<EpisodeCredits<BasicPerson>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(data.episodeNumber)), "credits")
    }
}
