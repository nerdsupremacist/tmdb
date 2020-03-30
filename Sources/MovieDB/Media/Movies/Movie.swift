
import Foundation
import GraphZahl
import NIO

// MARK: - MovieBase
class Movie: Decodable, GraphQLObject {
    enum CodingKeys: String, CodingKey {
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
    let releaseDate: Date?
    let id: Int
    let originalTitle, originalLanguage, title: String
    let backdrop: Image<BackdropSize>?
    let popularityIndex: Double?
    let numberOfRatings: Int
    let isVideo: Bool
    let rating: Double

    func details(client: Client) -> EventLoopFuture<DetailedMovie> {
        return client.get(at: "movie", .constant(String(id)))
    }
    
    func externalIds(client: Client) -> EventLoopFuture<ExternalIDS> {
        return client.get(at: "movie", .constant(String(id)), "external_ids")
    }

    func alternativeTitles(client: Client) -> EventLoopFuture<[AlternativeTitle]> {
        return client.get(at: "movie", .constant(String(id)), "alternative_titles").map { (wrapper: AlternativeTitles) in wrapper.titles }
    }

    func translations(client: Client) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return client.get(at: "movie", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(client: Client) -> EventLoopFuture<MediaImages> {
        return client.get(at: "movie", .constant(String(id)), "images")
    }

    func keywords(client: Client) -> EventLoopFuture<[Keyword]> {
        return client.get(at: "movie", .constant(String(id)), "keywords").map { (wrapper: Keywords) in wrapper.keywords }
    }

    func videos(client: Client) -> EventLoopFuture<[Video]> {
        return client.get(at: "movie", .constant(String(id)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func reviews(client: Client) -> EventLoopFuture<Paging<Review>> {
        return client.get(at: "movie", .constant(String(id)), "reviews")
    }

    func credits(client: Client) -> EventLoopFuture<Credits<BasicPerson>> {
        return client.get(at: "movie", .constant(String(id)), "credits")
    }

    func recommendations(client: Client) -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", .constant(String(id)), "recommendations")
    }

    func similar(client: Client) -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", .constant(String(id)), "similar")
    }
}
