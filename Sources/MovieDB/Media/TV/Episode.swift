
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

    func details(client: Client, context: MutableContext) -> EventLoopFuture<DetailedEpisode> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)))
    }

    func externalIds(client: Client, context: MutableContext) -> EventLoopFuture<ExternalIDS> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "external_ids")
    }

    func translations(client: Client, context: MutableContext) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return client.get(at: "tv", .constant(String(context.show.id)), "episode", .constant(String(episodeNumber)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(client: Client, context: MutableContext) -> EventLoopFuture<EpisodeImages> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "images")
    }

    func videos(client: Client, context: MutableContext) -> EventLoopFuture<[Video]> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(client: Client, context: MutableContext) -> EventLoopFuture<EpisodeCredits<BasicPerson>> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(episodeNumber)), "credits")
    }
}
