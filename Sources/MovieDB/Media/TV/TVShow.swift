
import Foundation
import GraphZahl
import NIO

class TVShow: Decodable, GraphQLObject {
    let poster: Image<PosterSize>?
    let popularityIndex: Double?
    let id: Int
    let backdrop: Image<BackdropSize>?
    let rating: Double
    let overview: String
    let firstAirDate: Date
    let originCountry: [String]
    let originalLanguage: String
    let numberOfRatings: Int
    let name, originalName: String

    enum CodingKeys: String, CodingKey {
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

    func details(client: Client) -> EventLoopFuture<DetailedTVShow> {
        return client.get(at: "tv", .constant(String(id)))
    }

    func externalIds(client: Client) -> EventLoopFuture<ExternalIDS> {
        return client.get(at: "tv", .constant(String(id)), "external_ids")
    }

    func alternativeTitles(client: Client) -> EventLoopFuture<[AlternativeTitle]> {
        return client.get(at: "tv", .constant(String(id)), "alternative_titles").map { (wrapper: AlternativeTitles) in wrapper.titles }
    }

    func translations(client: Client) -> EventLoopFuture<[Translation<TranslatedMovieInfo>]> {
        return client.get(at: "tv", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func images(client: Client) -> EventLoopFuture<MediaImages> {
        return client.get(at: "tv", .constant(String(id)), "images")
    }

    func keywords(client: Client) -> EventLoopFuture<[Keyword]> {
        return client.get(at: "tv", .constant(String(id)), "keywords").map { (wrapper: Keywords) in wrapper.keywords }
    }

    func videos(client: Client) -> EventLoopFuture<[Video]> {
        return client.get(at: "tv", .constant(String(id)), "videos").map { (wrapper: Videos) in wrapper.results }
    }

    func reviews(client: Client) -> EventLoopFuture<Paging<Review>> {
        return client.get(at: "tv", .constant(String(id)), "reviews")
    }

    func credits(client: Client) -> EventLoopFuture<Credits<BasicPerson>> {
        return client.get(at: "tv", .constant(String(id)), "credits")
    }

    func recommendations(client: Client) -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", .constant(String(id)), "recommendations")
    }

    func similar(client: Client) -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", .constant(String(id)), "similar")
    }
}
