
import Foundation
import GraphZahl
import GraphQL
import NIO
import ContextKit

class DetailedTVShow: TVShow {
    let createdBy: [BaseCredit<BasicPerson>]
    let episodeRunTime: [Int]
    let genres: [Genre]
    let homepage: URL?
    let inProduction: Bool
    let languages: [String]
    let lastAirDate: Date?
    let lastEpisodeToAir: Episode?
    let nextEpisodeToAir: Episode?
    let networks: [Network]
    let numberOfEpisodes, numberOfSeasons: Int
    let productionCompanies: [Network]
    let seasons: [SeasonResult]
    let status, type: String

    private enum CodingKeys: String, CodingKey {
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
        let container = try decoder.container(keyedBy: CodingKeys.self)
        createdBy = try container.decode([BaseCredit<BasicPerson>].self, forKey: .createdBy)
        episodeRunTime = try container.decode([Int].self, forKey: .episodeRunTime)
        genres = try container.decode([Genre].self, forKey: .genres)
        let homepageString = try container.decodeIfPresent(String.self, forKey: .homepage)
        homepage = homepageString.flatMap(URL.init(string:))
        inProduction = try container.decode(Bool.self, forKey: .inProduction)
        languages = try container.decode([String].self, forKey: .languages)
        lastAirDate = try container.decode(Date?.self, forKey: .lastAirDate)
        lastEpisodeToAir = try container.decodeIfPresent(Episode.self, forKey: .lastEpisodeToAir)
        nextEpisodeToAir = try container.decodeIfPresent(Episode.self, forKey: .nextEpisodeToAir)
        networks = try container.decode([Network].self, forKey: .networks)
        numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        numberOfSeasons = try container.decode(Int.self, forKey: .numberOfSeasons)
        productionCompanies = try container.decode([Network].self, forKey: .productionCompanies)
        seasons = try container.decode([SeasonResult].self, forKey: .seasons)
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        try super.init(from: decoder)
    }
}
