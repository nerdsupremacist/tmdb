
import Foundation
import GraphZahl
import NIO
import ContextKit

class Episode: Decodable, GraphQLObject {
    let airDate: Date
    let episodeNumber, id: Int
    let name, overview, productionCode: String
    let seasonNumber: Int
    let still: Image<StillSize>?
    let voteAverage: Double
    let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case still = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    func details(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<DetailedEpisode> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)))
    }

    func externalIds(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<ExternalIDS> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "external_ids")
    }

    func translations(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "episode", .constant(String(episodeNumber)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<EpisodeImages> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "images")
    }

    func videos(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<EpisodeCredits<BasicPerson>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "credits")
    }
}
