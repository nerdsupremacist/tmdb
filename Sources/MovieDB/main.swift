
import Foundation
import GraphZahl
import NIO
import Vapor
import GraphZahlVaporSupport

let app = Application(try .detect())

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 10)
let cache = Cache<URL, HTTPClient.Response>()

let base = URL(string: "https://api.themoviedb.org/3/")!
let imagesBase = URL(string: "https://image.tmdb.org/t/p/")!

guard let apiKey = ProcessInfo.processInfo.environment["API_KEY"] else {
    fatalError("Did not provide an API Key")
}

app.routes.graphql(use: MovieDB.self, eventLoopGroup: nil, includeGraphiQL: true) { request -> Client in
    let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    return Client(base: base,
                  imagesBase: imagesBase,
                  apiKey: apiKey,
                  httpClient: httpClient,
                  cache: cache)
}

try app.run()
