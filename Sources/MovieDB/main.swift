
import Foundation
import GraphZahl
import NIO
import Vapor
import Cache
import GraphZahlVaporSupport
import Backtrace

Backtrace.install()
let app = Application(try .detect())

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let cacheConfig = MemoryConfig(expiry: .never, countLimit: 500, totalCostLimit: 100_000)
let cache = MemoryStorage<Client.CacheEntry, Any>(config: cacheConfig)

let tmdbBase = URL(string: "https://api.themoviedb.org/3/")!
let tmdbImageBase = URL(string: "https://image.tmdb.org/t/p/")!
let justWatchBase = URL(string: "https://apis.justwatch.com/content/")!
let justWatchImageBase = URL(string: "https://images.justwatch.com")!
let geoLocationBase = URL(string: "https://api.ipgeolocation.io/")!

guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
    fatalError("Did not provide an API Key")
}

struct TMDBAPIKeyAuthenticator: Authenticator {
    let apiKey: String

    func authenticate(with queryParamters: inout [URLQueryItem]) {
        queryParamters += [URLQueryItem(name: "api_key", value: apiKey)]
    }
}

struct GeoLocationAPIKeyAuthenticator: Authenticator {
    let apiKey: String

    func authenticate(with queryParamters: inout [URLQueryItem]) {
        queryParamters += [URLQueryItem(name: "apiKey", value: apiKey)]
    }
}

app.routes.graphql(use: MovieDB.self, eventLoopGroup: nil, ideEnabled: .always(.playground)) { request -> MovieDB.ViewerContext in
    let tmdbHTTPClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    let tmdb = Client(base: tmdbBase,
                      authenticator: TMDBAPIKeyAuthenticator(apiKey: apiKey),
                      httpClient: tmdbHTTPClient,
                      cache: cache)

    let justWatchClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    let justWatch = Client(base: justWatchBase,
                           httpClient: justWatchClient,
                           cache: cache)

    let geoLocationClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    let geoLocation = Client(base: geoLocationBase,
                             authenticator: GeoLocationAPIKeyAuthenticator(apiKey: "eee9c9c23de44033a19b44be776e3a42"),
                             httpClient: geoLocationClient,
                             cache: cache)

    return MovieDB.ViewerContext(request: request, tmdbImageBase: tmdbImageBase, justWatchImageBase: justWatchImageBase, tmdb: tmdb, justWatch: justWatch, geoLocation: geoLocation)
}

try app.run()
