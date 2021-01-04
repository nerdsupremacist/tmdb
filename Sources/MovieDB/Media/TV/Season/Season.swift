
import Foundation
import GraphZahl
import NIO

class Season: GraphQLObject {
    @Inline
    var data: SeasonData

    @Ignore
    var showName: String

    @Ignore
    var showId: Int

    init(data: SeasonData, showName: String, showId: Int) {
        self.data = data
        self.showName = showName
        self.showId = showId
    }

    func streamingOptions(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[StreamingOption]?> {
        return viewerContext.streampingOptionsForSeason(showId: showId, showName: showName, seasonNumber: data.seasonNumber)
    }

    func details(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<DetailedSeason> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber))).map { data in
            DetailedSeason(data: data, showName: self.showName, showId: self.showId)
        }
    }

    func episode(viewerContext: MovieDB.ViewerContext, number: Int) -> EventLoopFuture<DetailedEpisode> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "episode", .constant(String(number))).map { data in
            DetailedEpisode(data: data, showName: self.showName, showId: self.showId)
        }
    }

    func externalIds(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<ExternalIDS> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "external_ids")
    }

    func images(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<MediaImages> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "images")
    }

    func videos(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<BasicPerson>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "credits")
    }
}
