
import Foundation
import GraphZahl
import ContextKit
import NIO

class Season: Decodable, GraphQLObject {
    let airDate: Date?
    let id: Int
    let name: String
    let overview: String?
    let poster: Image<PosterSize>?
    let seasonNumber: Int

    private enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case id, name, overview
        case poster = "poster_path"
        case seasonNumber = "season_number"
    }

    func details(client: Client, context: MutableContext) -> EventLoopFuture<DetailedSeason> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)))
    }
    
    func episode(client: Client, context: MutableContext, number: Int) -> EventLoopFuture<DetailedEpisode> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(number)))
    }

    func externalIds(client: Client, context: MutableContext) -> EventLoopFuture<ExternalIDS> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "external_ids")
    }

    func images(client: Client, context: MutableContext) -> EventLoopFuture<MediaImages> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "images")
    }

    func videos(client: Client, context: MutableContext) -> EventLoopFuture<[Video]> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(client: Client, context: MutableContext) -> EventLoopFuture<Credits<BasicPerson>> {
        return client.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "credits")
    }
}
