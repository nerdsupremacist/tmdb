
import Foundation
import GraphZahl
import NIO
import CloudKit

// MARK: - MovieBase
class BasicMovie: Decodable, GraphQLObject {
    private enum CodingKeys: String, CodingKey {
        case poster = "poster_path"
        case isAdult = "adult"
        case overview
        case releaseDate = "release_date"
        case id
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case title
        case backdrop = "backdrop_path"
        case popularityIndex = "popularity"
        case numberOfRatings = "vote_count"
        case isVideo = "video"
        case rating = "vote_average"
    }

    let poster: Image<PosterSize>?
    let isAdult: Bool
    let overview: String
    let releaseDate: OptionalDate?
    let id: Int
    let originalTitle, originalLanguage, title: String
    let backdrop: Image<BackdropSize>?
    let popularityIndex: Double?
    let numberOfRatings: Int
    let isVideo: Bool
    let rating: Double

    func streamingOptions(viewerContext: MovieDB.ViewerContext, country: ID?) -> EventLoopFuture<[StreamingOption]?> {
        let locale: EventLoopFuture<String?> = country?
            .idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop)
            .map(Optional.some) ?? viewerContext.request.eventLoop.future(nil)

        return locale.flatMap { locale in
            return viewerContext.streamingOptions(id: self.id, name: self.title, contentType: .movie, locale: locale)
        }
    }

    func externalIds(viewerContext: MovieDB.ViewerContext) -> FullExternalIDS {
        return .movie(id: id, viewerContext: viewerContext)
    }

    func alternativeTitles(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[AlternativeTitle]> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "alternative_titles").map { (wrapper: AlternativeTitles) in wrapper.titles }
    }

    func translations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<MediaImages> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "images")
    }

    func keywords(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Keyword]> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "keywords").map { (wrapper: Keywords) in wrapper.keywords }
    }

    func videos(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Video]> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func reviews(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Paging<Review>> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "reviews")
    }

    func credits(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<Person>> {
        return viewerContext.tmdb.get(at: "movie", .constant(String(id)), "credits").map { (credits: Credits<BasicPerson>) in
            return credits.map { Person(person: $0, viewerContext: viewerContext) }
        }
    }

    func recommendations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "movie", .constant(String(id)), "recommendations")
    }

    func similar(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "movie", .constant(String(id)), "similar")
    }
}
