
import Foundation
import GraphZahl
import NIO

class BasicEpisode: GraphQLObject {
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

    func show(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow> {
        return viewerContext.tmdb.show(id: showId).map { TVShow(details: $0, viewerContext: viewerContext) }
    }

    func season(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Season> {
        return viewerContext.season(showId: showId, seasonNumber: data.seasonNumber, showName: showName).map { Season(details: $0, viewerContext: viewerContext) }
    }

    func streamingOptions(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[StreamingOption]?> {
        return viewerContext.streampingOptionsForEpisode(showId: showId, showName: showName, seasonNumber: data.seasonNumber, episodeNumber: data.episodeNumber)
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

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<EpisodeCredits<Person>> {
        return viewerContext
            .tmdb
            .get(
                at: "tv",
                .constant(String(showId)),
                "season",
                .constant(String(data.seasonNumber)),
                "episode",
                .constant(String(data.episodeNumber)),
                "credits"
            )
            .map { (credits: EpisodeCredits<BasicPerson>) in
                return credits.map { Person(person: $0, viewerContext: viewerContext) }
            }
    }
}
