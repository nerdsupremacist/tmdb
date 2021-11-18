
import Foundation
import GraphZahl
import NIO
import GraphQL
import ContextKit

class BasicTVShow: Decodable, GraphQLObject {
    let poster: Image<PosterSize>?
    let popularityIndex: Double?
    let id: Int
    let backdrop: Image<BackdropSize>?
    let rating: Double
    let overview: String
    let firstAirDate: OptionalDate?
    let originCountry: [String]
    let originalLanguage: String
    let numberOfRatings: Int
    let name, originalName: String

    private enum CodingKeys: String, CodingKey {
        case poster = "poster_path"
        case popularityIndex = "popularity"
        case id
        case backdrop = "backdrop_path"
        case rating = "vote_average"
        case overview
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case numberOfRatings = "vote_count"
        case name
        case originalName = "original_name"
    }

    func season(viewerContext: MovieDB.ViewerContext, number: Int) -> EventLoopFuture<Season> {
        return viewerContext
            .season(showId: id, seasonNumber: number, showName: name)
            .map { Season(details: $0, viewerContext: viewerContext) }
    }

    func externalIds(viewerContext: MovieDB.ViewerContext) -> FullExternalIDS {
        return .show(id: id, viewerContext: viewerContext)
    }

    func alternativeTitles(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[AlternativeTitle]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "alternative_titles").map { (wrapper: AlternativeTitles) in wrapper.titles }
    }

    func translations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<MediaImages> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "images")
    }

    func keywords(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Keyword]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "keywords").map { (wrapper: TVShowKeywords) in wrapper.results }
    }

    func videos(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func reviews(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Paging<Review>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "reviews")
    }

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<Person>> {
        return viewerContext.tmdb.get(at: "tv", .constant(String(id)), "credits").map { (credits: Credits<BasicPerson>) in
            return credits.map { Person(person: $0, viewerContext: viewerContext) }
        }
    }

    func recommendations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", .constant(String(id)), "recommendations")
    }

    func similar(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "tv", .constant(String(id)), "similar")
    }
}

private struct TVShowKeywords: Decodable {
    let results: [Keyword]
}
