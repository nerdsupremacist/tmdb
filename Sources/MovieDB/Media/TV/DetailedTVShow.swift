
import Foundation
import GraphZahl
import GraphQL
import NIO
import ContextKit

class DetailedTVShow: BasicTVShow {
    @Ignore
    var internalCreatedBy: [BaseCredit<BasicPerson>]

    let episodeRunTime: [Int]
    let genres: [Genre]
    let homepage: URL?
    let inProduction: Bool
    let languages: [String]
    let lastAirDate: Date?
    let networks: [Network]
    let numberOfEpisodes, numberOfSeasons: Int
    let productionCompanies: [Network]
    let status, type: String

    @Ignore
    var internalLastEpisodeToAir: BasicEpisode?

    @Ignore
    var internalNextEpisodeToAir: BasicEpisode?

    @Ignore
    var internalSeasons: [SeasonResult]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
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
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        internalCreatedBy = try container.decode([BaseCredit<BasicPerson>].self, forKey: .createdBy)
        episodeRunTime = try container.decode([Int].self, forKey: .episodeRunTime)
        genres = try container.decode([Genre].self, forKey: .genres)
        let homepageString = try container.decodeIfPresent(String.self, forKey: .homepage)
        homepage = homepageString.flatMap(URL.init(string:))
        inProduction = try container.decode(Bool.self, forKey: .inProduction)
        languages = try container.decode([String].self, forKey: .languages)
        lastAirDate = try container.decode(Date?.self, forKey: .lastAirDate)
        internalLastEpisodeToAir = try container.decodeIfPresent(EpisodeData.self, forKey: .lastEpisodeToAir).map { BasicEpisode(data: $0, showName: name, showId: id) }
        internalNextEpisodeToAir = try container.decodeIfPresent(EpisodeData.self, forKey: .nextEpisodeToAir).map { BasicEpisode(data: $0, showName: name, showId: id) }
        networks = try container.decode([Network].self, forKey: .networks)
        numberOfEpisodes = try container.decode(Int.self, forKey: .numberOfEpisodes)
        numberOfSeasons = try container.decode(Int.self, forKey: .numberOfSeasons)
        productionCompanies = try container.decode([Network].self, forKey: .productionCompanies)
        internalSeasons = try container.decode([SeasonResultData].self, forKey: .seasons).map { SeasonResult(data: $0, showName: name, showId: id) }
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        try super.init(from: decoder)
    }

    func seasons(viewerContext: MovieDB.ViewerContext) -> [Season] {
        return internalSeasons
            .sorted { lhs, rhs in
                if (lhs.data.seasonNumber == 0) {
                    return false
                }
                if (rhs.data.seasonNumber == 0) {
                    return true
                }
                return lhs.data.seasonNumber < rhs.data.seasonNumber
            }
            .map { Season(season: $0.season, viewerContext: viewerContext) }
    }

    func episodes(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Episode]> {
        return internalSeasons
            .map { viewerContext.season(showId: id, seasonNumber: $0.data.seasonNumber, showName: name) }
            .flatten(on: viewerContext.request.eventLoop.next())
            .map { $0.flatMap { $0.episodes(viewerContext: viewerContext) } }
            .map { episodes in
                episodes.sorted { lhs, rhs in
                    switch (lhs.episode.data.airDate?.wrappedValue, rhs.episode.data.airDate?.wrappedValue) {
                    case (.some(let lhs), .some(let rhs)):
                        return lhs < rhs
                    case (.some, .none):
                        return true
                    default:
                        return false
                    }
                }
            }
    }

    func topRatedEpisode(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Episode?> {
        let now = Date()
        return episodes(viewerContext: viewerContext)
            .map { episodes in
                episodes
                    .filter { $0.episode.data.airDate?.wrappedValue.map { $0 < now } ?? false }
                    .filter { $0.episode.data.voteAverage > 0 }
                    .max { $0.episode.data.voteAverage < $1.episode.data.voteAverage }
            }
    }

    func createdBy(viewerContext: MovieDB.ViewerContext) -> [BaseCredit<Person>] {
        return internalCreatedBy.map { $0.map { Person(person: $0, viewerContext: viewerContext) } }
    }

    func lastEpisodeToAir(viewerContext: MovieDB.ViewerContext) -> Episode? {
        return internalLastEpisodeToAir.map { Episode(episode: $0, viewerContext: viewerContext) }
    }

    func nextEpisodeToAir(viewerContext: MovieDB.ViewerContext) -> Episode? {
        return internalNextEpisodeToAir.map { Episode(episode: $0, viewerContext: viewerContext) }
    }
}
