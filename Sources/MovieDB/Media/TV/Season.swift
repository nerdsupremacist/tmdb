
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

    func details(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<DetailedSeason> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)))
    }
    
    func episode(viewerContext: MovieDB.ViewerContext, context: MutableContext, number: Int) -> EventLoopFuture<DetailedEpisode> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "episode", .constant(String(number)))
    }

    func externalIds(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<ExternalIDS> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "external_ids")
    }

    func images(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<MediaImages> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "images")
    }

    func videos(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(viewerContext: MovieDB.ViewerContext, context: MutableContext) -> EventLoopFuture<Credits<BasicPerson>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(context.show.id)), "season", .constant(String(seasonNumber)), "credits")
    }
}
