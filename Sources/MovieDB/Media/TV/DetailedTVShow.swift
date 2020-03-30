
import Foundation
import GraphZahl

class DetailedTVShow: TVShow {
    let createdBy: [BaseCredit<BasicPerson>]
    let episodeRunTime: [Int]
    let genres: [Genre]
//    let homepage: URL?
    let inProduction: Bool
    let languages: [String]
    let lastAirDate: Date?
    let lastEpisodeToAir: Episode?
    let nextEpisodeToAir: Episode?
    let networks: [Network]
    let numberOfEpisodes, numberOfSeasons: Int
    let productionCompanies: [Network]
    let seasons: [Season]
    let status, type: String

    enum CodingKeys: String, CodingKey {
        case createdBy = "created_by"
        case episodeRunTime = "episode_run_time"
        case genres, homepage
        case inProduction = "in_production"
        case languages
        case lastAirDate = "last_air_date"
        case lastEpisodeToAir = "last_episode_to_air"
        case nextEpisodeToAir = "next_episode_to_air"
        case networks
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case productionCompanies = "production_companies"
        case seasons, status, type
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailedTVShow.CodingKeys.self)
        createdBy = try container.decode([BaseCredit<BasicPerson>].self, forKey: .createdBy)
        episodeRunTime = try container.decode([Int].self, forKey: .episodeRunTime)
        genres = try container.decode([Genre].self, forKey: .genres)
//        homepage = try container.decode(URL?.self, forKey: .homepage)
        inProduction = try container.decode(Bool.self, forKey: .inProduction)
        languages = try container.decode([String].self, forKey: .languages)
        lastAirDate = try container.decode(Date?.self, forKey: .lastAirDate)
        lastEpisodeToAir = try container.decode(Episode?.self, forKey: .lastEpisodeToAir)
        nextEpisodeToAir = try container.decode(Episode?.self, forKey: .nextEpisodeToAir)
        networks = try container.decode([Network].self, forKey: .networks)
        numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        numberOfSeasons = try container.decode(Int.self, forKey: .numberOfSeasons)
        productionCompanies = try container.decode([Network].self, forKey: .productionCompanies)
        seasons = try container.decode([Season].self, forKey: .seasons)
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        try super.init(from: decoder)
    }
}

class Episode: Decodable, GraphQLObject {
    let airDate: String
    let episodeNumber, id: Int
    let name, overview, productionCode: String
    let seasonNumber, showID: Int
    let still: Image<StillSize>?
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeNumber = "episode_number"
        case id, name, overview
        case productionCode = "production_code"
        case seasonNumber = "season_number"
        case showID = "show_id"
        case still = "still_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

class Network: Decodable, GraphQLObject {
    let name: String
    let id: Int
    let logo: Image<LogoSize>?
    let originCountry: String

    enum CodingKeys: String, CodingKey {
        case name, id
        case logo = "logo_path"
        case originCountry = "origin_country"
    }
}

class Season: Decodable, GraphQLObject {
    let airDate: Date?
    let episodeCount, id: Int
    let name: String
    let overview: String?
    let poster: Image<PosterSize>?
    let seasonNumber: Int

    enum CodingKeys: String, CodingKey {
        case airDate = "air_date"
        case episodeCount = "episode_count"
        case id, name, overview
        case poster = "poster_path"
        case seasonNumber = "season_number"
    }
}
