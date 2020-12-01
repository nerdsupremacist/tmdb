
import Foundation
import GraphZahl
import NIO

class DetailedMovie: Movie {
    private enum CodingKeys: String, CodingKey {
        case budget, genres, homepage
        case imdbID = "imdb_id"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline
    }

    enum Status: String, Decodable, CaseIterable, GraphQLEnum {
        case rumored = "Rumored"
        case planned = "Planned"
        case inProduction = "In Production"
        case postProduction = "Post Production"
        case released = "Released"
        case cancelled = "Cancelled"
    }

    let budget: Int?
    let genres: [Genre]
//    let homepage: URL?
    let imdbID: String
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let revenue, runtime: Int
    let spokenLanguages: [SpokenLanguage]
    let status: Status
    let tagline: String

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        budget = try container.decode(Int?.self, forKey: .budget)
        genres = try container.decode([Genre].self, forKey: .genres)
//        homepage = try container.decode(URL?.self, forKey: .homepage)
        imdbID = try container.decode(String.self, forKey: .imdbID)
        productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        productionCountries = try container.decode([ProductionCountry].self, forKey: .productionCountries)
        revenue = try container.decode(Int.self, forKey: .revenue)
        runtime = try container.decode(Int.self, forKey: .runtime)
        spokenLanguages = try container.decode([SpokenLanguage].self, forKey: .spokenLanguages)
        status = try container.decode(Status.self, forKey: .status)
        tagline = try container.decode(String.self, forKey: .tagline)
        try super.init(from: decoder)
    }
}

class Genre: Codable, GraphQLObject {
    let id: Int
    let name: String
}

class ProductionCompany: Decodable, GraphQLObject {
    let id: Int
    let logo: Image<LogoSize>?
    let name, originCountry: String

    private enum CodingKeys: String, CodingKey {
        case id
        case logo = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

class ProductionCountry: Codable, GraphQLObject {
    let iso3166_1, name: String

    private enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}

class SpokenLanguage: Codable, GraphQLObject {
    let iso639_1, name: String

    private enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case name
    }
}
