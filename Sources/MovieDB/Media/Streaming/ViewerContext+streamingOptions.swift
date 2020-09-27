
import Foundation
import NIO

extension MovieDB.ViewerContext {

    enum ContentType: String {
        case movie
        case show
    }

    func streamingOptions(id: Int, name: String, contentType: ContentType) -> EventLoopFuture<[StreamingOption]?> {
        return locale()
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
                guard let offers = item?.offers else { return nil }
                let groupped = Dictionary(grouping: offers, by: { $0.providerID })
                return groupped
                    .map { StreamingOption(providerID: $0.key, offerings: $0.value.map { StreamingOptionOffering(decoded: $0) }) }
                    .sorted { $0.providerID < $1.providerID }
                    .sorted { $0.bestOffering.isBetterThan(other: $1.bestOffering) }
            }
    }

    func streamingProviders() -> EventLoopFuture<[StreamingProvider]?> {
        return locale()
            .flatMap { locale -> EventLoopFuture<[StreamingProvider]?> in
                guard let locale = locale else { return self.request.eventLoop.future(nil) }
                return self.justWatch.get(at: "providers", "locale", .constant(locale), expiry: .pseudoDays(3))
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
    let title: String
    let offers: [DecodedStreamingOption]?
    let scoring: [Scoring]?
}

class Scoring: Decodable {
    let providerType: String
    let value: Double

    enum CodingKeys: String, CodingKey {
        case providerType = "provider_type"
        case value
    }
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
