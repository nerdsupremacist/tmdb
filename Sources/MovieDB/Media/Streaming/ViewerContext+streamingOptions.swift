
import Foundation
import NIO

extension MovieDB.ViewerContext {

    enum ContentType: String {
        case movie
        case show
    }

    func countries() -> EventLoopFuture<[StreamingCountry]> {
        return justWatch.get(at: ["locales", "state"])
    }

    func streamingOptions(id: Int, name: String, contentType: ContentType, locale: String?) -> EventLoopFuture<[StreamingOption]?> {
        return justWatchItem(id: id, name: name, contentType: contentType, locale: locale)
            .map { item in
                guard let offers = item?.offers else { return nil }
                let groupped = Dictionary(grouping: offers, by: { $0.providerID })
                return groupped
                    .map { StreamingOption(providerID: $0.key, offerings: $0.value.map { StreamingOptionOffering(decoded: $0) }) }
                    .sorted { $0.providerID < $1.providerID }
                    .sorted { $0.bestOffering.isBetterThan(other: $1.bestOffering) }
            }
    }

    func streamingProviders(locale: String?) -> EventLoopFuture<[StreamingProvider]?> {
        return self.locale(locale: locale)
            .flatMap { locale -> EventLoopFuture<[StreamingProvider]?> in
                guard let locale = locale else { return self.request.eventLoop.future(nil) }
                return self.justWatch.get(at: "providers", "locale", .constant(locale), expiry: .pseudoDays(3))
            }
    }

    func streampingOptionsForSeason(showId: Int, showName: String, seasonNumber: Int, locale: String?) -> EventLoopFuture<[StreamingOption]?> {
        return justWatchSeason(showId: showId, showName: showName, seasonNumber: seasonNumber, locale: locale).map { season in
            guard let offers = season?.offers else { return nil }
            let groupped = Dictionary(grouping: offers, by: { $0.providerID })
            return groupped
                .map { StreamingOption(providerID: $0.key, offerings: $0.value.map { StreamingOptionOffering(decoded: $0) }) }
                .sorted { $0.providerID < $1.providerID }
                .sorted { $0.bestOffering.isBetterThan(other: $1.bestOffering) }
        }
    }

    func streampingOptionsForEpisode(showId: Int, showName: String, seasonNumber: Int, episodeNumber: Int, locale: String?) -> EventLoopFuture<[StreamingOption]?> {
        return justWatchSeason(showId: showId, showName: showName, seasonNumber: seasonNumber, locale: locale).map { season in
            guard let offers = season?.episodes?.first(where: { $0.number == episodeNumber })?.offers else { return nil }
            let groupped = Dictionary(grouping: offers, by: { $0.providerID })
            return groupped
                .map { StreamingOption(providerID: $0.key, offerings: $0.value.map { StreamingOptionOffering(decoded: $0) }) }
                .sorted { $0.providerID < $1.providerID }
                .sorted { $0.bestOffering.isBetterThan(other: $1.bestOffering) }
        }
    }

}

extension MovieDB.ViewerContext {

    private func justWatchSeason(showId: Int, showName: String, seasonNumber: Int, locale: String?) -> EventLoopFuture<JustWatchSeasonDetails?> {
        let showId = justWatchItem(id: showId, name: showName, contentType: .show, locale: locale).map { $0?.id }
        let locale = self.locale(locale: locale)
        return showId
            .and(locale)
            .flatMap { (showId, locale) -> EventLoopFuture<JustWatchShowDetails?> in
                guard let showId = showId, let locale = locale else { return self.justWatch.eventLoop.future(nil) }
                return self.justWatch.get(at: "titles", "show", .constant(String(showId)), "locale", .constant(locale))
            }
            .map { $0?.seasons.first { $0.number == seasonNumber } }
            .and(locale)
            .flatMap { (season, locale) -> EventLoopFuture<JustWatchSeasonDetails?> in
                guard let season = season, let locale = locale else { return self.justWatch.eventLoop.future(nil) }
                return self.justWatch.get(at: "titles", "show_season", .constant(String(season.id)), "locale", .constant(locale))
            }
    }

    private func justWatchItem(id: Int, name: String, contentType: ContentType, locale: String?) -> EventLoopFuture<JustWatchItem?> {
        return self.locale(locale: locale)
            .flatMap { locale -> EventLoopFuture<JustWatchResponse?> in
                guard let locale = locale else { return self.request.eventLoop.future(nil) }
                let body: JSON = .dictionary([
                    "query" : .string(name),
                    "content_types" : .array([.string(contentType.rawValue)]),
                    "page_size" : .int(10),
                ])
                return self.justWatch.post(at: "titles", .constant(locale), "popular", body: body, expiry: .pseudoDays(3))
            }
            .map { response in
                guard let response = response else { return nil }
                let item = response.items.first { $0.scoring?.contains { $0.providerType == "tmdb:id" && $0.value == Double(id) } ?? false } ?? response.items.first { $0.title == name }
                return item
            }
    }

}

private struct JustWatchResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case items
    }

    let items: [JustWatchItem]
}

private struct JustWatchItem: Decodable {
    let id: Int
    let title: String
    let offers: [DecodedStreamingOption]?
    let scoring: [Scoring]?
}

private struct Scoring: Decodable {
    let providerType: String
    let value: Double

    enum CodingKeys: String, CodingKey {
        case providerType = "provider_type"
        case value
    }
}

private struct JustWatchSeason: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case number = "season_number"
    }

    let id: Int
    let number: Int
}

private struct JustWatchShowDetails: Decodable {
    let seasons: [JustWatchSeason]
}

private struct JustWatchSeasonDetails: Decodable {
    let offers: [DecodedStreamingOption]?
    let episodes: [JustWatchEpisode]?
}

private struct JustWatchEpisode: Decodable {
    enum CodingKeys: String, CodingKey {
        case offers
        case number = "episode_number"
    }

    let offers: [DecodedStreamingOption]?
    let number: Int
}

struct DecodedStreamingOption: Decodable {
    enum CodingKeys: String, CodingKey {
        case type = "monetization_type"
        case providerID = "provider_id"
        case retailPrice = "retail_price"
        case currency
        case links = "urls"
        case resolution = "presentation_type"
    }

    let type: StreamingMonetizationType
    let providerID: Int

    let retailPrice: Double?
    let currency: String?

    let links: StreamingLinks
    let resolution: VideoResolution
}
