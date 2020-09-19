
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphQL
import ContextKit

class JustWatchResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case items
    }

    let items: [JustWatchItem]
}

class JustWatchItem: Decodable {
    let title: String
    let offers: [DecodedStreamingOption]?
    let scoring: [Scoring]
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
    let currency: String

    let links: StreamingLinks
    let resolution: VideoResolution
}

class StreamingOption: GraphQLObject {
    @Ignore
    final var providerID: Int
    let bestOffering: StreamingOptionOffering
    let offerings: [StreamingOptionOffering]

    init(providerID: Int, offerings: [StreamingOptionOffering]) {
        self.providerID = providerID
        self.bestOffering = offerings.min { $0.isBetterThan(other: $1) }!
        self.offerings = offerings
    }

    func provider(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<StreamingProvider> {
        return viewerContext.streamingProviders().flatMapThrowing { providers in
            guard let provider = providers?.first(where: { $0.id == self.providerID }) else {
                throw Abort(.notFound)
            }
            return provider
        }
    }
}

class StreamingOptionOffering: GraphQLObject {
    let price: Price?
    let type: StreamingMonetizationType
    let resolution: VideoResolution
    let links: StreamingLinks

    init(decoded: DecodedStreamingOption) {
        self.price = decoded.retailPrice.map { Price(amount: $0, currency: decoded.currency) }
        self.type = decoded.type
        self.resolution = decoded.resolution
        self.links = decoded.links
    }

    func isBetterThan(other: StreamingOptionOffering) -> Bool {
        if type.ranking < other.type.ranking {
            return true
        }

        if type.ranking > other.type.ranking {
            return false
        }

        if resolution.ranking < other.resolution.ranking {
            return true
        }

        if resolution.ranking > other.resolution.ranking {
            return false
        }

        switch (price, other.price) {
        case (.none, .none):
            return false
        case (.some(let lhs), .some(let rhs)):
            if lhs.currency == rhs.currency {
                return lhs.amount < rhs.amount
            }
            return false
        case (.none, _):
            return true
        case (_, .none):
            return false
        }
    }
}

struct StreamingProviderIconURL: Decodable, DelegatedOutputResolvable {
    let path: String

    init(from decoder: Decoder) throws {
        self.path = try String(from: decoder)
    }

    func url(viewerContext: MovieDB.ViewerContext) -> URL {
        return viewerContext.justWatchImageBase.appendingPathComponent(path.replacingOccurrences(of: "{profile}", with: "s100"))
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        return url(viewerContext: context.anyViewerContext as! MovieDB.ViewerContext)
    }
}

class Price: GraphQLObject {
    let amount: Double
    let currency: String

    init(amount: Double, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

enum StreamingMonetizationType: String, Decodable, CaseIterable, GraphQLEnum {
    case ads = "ads"
    case buy = "buy"
    case cinema = "cinema"
    case flatrate = "flatrate"
    case free = "free"
    case rent = "rent"
}

extension StreamingMonetizationType {

    var ranking: Int {
        switch self {
        case .free:
            return 0
        case .flatrate:
            return 1
        case .ads:
            return 2
        case .rent:
            return 3
        case .cinema:
            return 4
        case .buy:
            return 5
        }
    }

}

enum VideoResolution: String, Decodable, CaseIterable, GraphQLEnum {
    case dvd
    case bluray
    case sd
    case hd
    case ultraHD

    init(from decoder: Decoder) throws {
        let rawValue = try String(from: decoder)
        switch rawValue {
        case "4k":
            self = .ultraHD
        default:
            break
        }

        guard let resolution = VideoResolution(rawValue: rawValue) else {
            throw DecodingError.typeMismatch(VideoResolution.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value \(rawValue) is not supported by VideoResolution"))
        }

        self = resolution
    }
}

extension VideoResolution {

    var ranking: Int {
        switch self {
        case .ultraHD:
            return 0
        case .hd:
            return 1
        case .sd:
            return 2
        case .bluray:
            return 3
        case .dvd:
            return 4
        }
    }

}

class StreamingLinks: Decodable, GraphQLObject {
    enum CodingKeys: String, CodingKey {
        case web = "standard_web"
        case androidTV = "deeplink_android_tv"
        case tvOS = "deeplink_tvos"
        case fireTV = "deeplink_fire_tv"
    }

    let web: URL
    let androidTV: URL?
    let tvOS: URL?
    let fireTV: URL?
}

class StreamingProvider: Decodable, GraphQLObject {
    let id: Int
    let slug, name: String
    let monetizationTypes: [StreamingMonetizationType]
    let iconURL: StreamingProviderIconURL

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name = "clear_name"
        case monetizationTypes = "monetization_types"
        case iconURL = "icon_url"
    }
}
