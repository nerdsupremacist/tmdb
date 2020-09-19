
import Foundation
import Vapor
import GraphZahl
import NIO

enum MovieDB : GraphQLSchema {
    class ViewerContext {
        let request: Request
        let tmdbImageBase: URL
        let justWatchImageBase: URL
        let tmdb: Client
        let justWatch: Client
        let geoLocation: Client

        init(request: Request, tmdbImageBase: URL, justWatchImageBase: URL, tmdb: Client, justWatch: Client, geoLocation: Client) {
            self.request = request
            self.tmdbImageBase = tmdbImageBase
            self.justWatchImageBase = justWatchImageBase
            self.tmdb = tmdb
            self.justWatch = justWatch
            self.geoLocation = geoLocation
        }
    }

    class Query: QueryType {
        let viewerContext: ViewerContext

        var movies: Movies {
            return Movies(viewerContext: viewerContext)
        }

        var people: People {
            return People(viewerContext: viewerContext)
        }

        var tv: TV {
            return TV(viewerContext: viewerContext)
        }

        func search(term: String) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return viewerContext.tmdb.get(at: "search", "multi", query: ["query" : term])
        }

        func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return viewerContext.tmdb.get(at: "trending", "all", .constant(timeWindow.rawValue))
        }

        func find(externalId: String, source: ExternalSource) -> EventLoopFuture<FromExternalIds> {
            return viewerContext.tmdb.get(at: "find", .constant(externalId), query: ["external_source" : source.rawValue + "_id"])
        }

        required init(viewerContext: ViewerContext) {
            self.viewerContext = viewerContext
        }
    }
}

extension MovieDB.ViewerContext {

    func locale() -> EventLoopFuture<String?> {
        if let ipAddress = request.headers.forwarded.first?.for ?? request.remoteAddress?.ipAddress, ipAddress != "127.0.0.1" {
            return geoLocation.get(at: "ipgeo", query: ["ip" : ipAddress], expiry: .pseudoDays(14))
                .map { (located: GeoLocated) in
                    return located.locale
                }
                .flatMapError { _ in self.request.eventLoop.future(nil) }
        }

        if let acceptedLocale = request.headers[.acceptLanguage].first {
            let locale = Locale(identifier: acceptedLocale)
            if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
                return request.eventLoop.future("\(languageCode)_\(regionCode)")
            }
        }

        // For debugging purposes return USA when running in localhost
        if request.application.environment == .development {
            return request.eventLoop.future("en_US")
        }

        return request.eventLoop.future(nil)
    }

}

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
                let item = response.items.first { $0.scoring.contains { $0.providerType == "tmdb:id" && $0.value == Double(id) } } ?? response.items.first { $0.title == name }
                guard let offers = item?.offers else { return nil }
                let groupped = Dictionary(grouping: offers, by: { $0.providerID })
                return groupped
                    .map { StreamingOption(providerID: $0.key, offerings: $0.value.map { StreamingOptionOffering(decoded: $0) }) }
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
