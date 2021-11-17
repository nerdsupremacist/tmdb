
import Foundation
import GraphZahl
import NIO

class BasicSeason: GraphQLObject {
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
    
    func show(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow> {
        return viewerContext.tmdb.show(id: showId).map { TVShow(details: $0, viewerContext: viewerContext) }
    }

    func streamingOptions(viewerContext: MovieDB.ViewerContext, country: ID?) -> EventLoopFuture<[StreamingOption]?> {
        let locale: EventLoopFuture<String?> = country?
            .idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop)
            .map(Optional.some) ?? viewerContext.request.eventLoop.future(nil)

        return locale.flatMap { locale in
            return viewerContext.streampingOptionsForSeason(showId: self.showId, showName: self.showName, seasonNumber: self.data.seasonNumber, locale: locale)
        }
    }

    func searchStreamingOptions(viewerContext: MovieDB.ViewerContext,
                                providers: [ID],
                                countries: [ID]?) -> EventLoopFuture<[StreamingResultForProvideer]> {

        return viewerContext.searchStreampingOptionsForSeason(showId: self.showId,
                                                              showName: self.showName,
                                                              seasonNumber: self.data.seasonNumber,
                                                              providers: providers,
                                                              countries: countries)
    }

    func episode(viewerContext: MovieDB.ViewerContext, number: Int) -> EventLoopFuture<Episode> {
        return viewerContext.episode(showId: showId, seasonNumber: data.seasonNumber, episodeNumber: number, showName: showName).map { details in
            Episode(details: details, viewerContext: viewerContext)
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

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<Person>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(showId)), "season", .constant(String(data.seasonNumber)), "credits").map { (credits: Credits<BasicPerson>) in
            return credits.map { Person(person: $0, viewerContext: viewerContext) }
        }
    }
}
