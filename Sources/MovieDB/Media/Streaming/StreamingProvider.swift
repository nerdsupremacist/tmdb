
import Foundation
import GraphZahl
import NIO

class StreamingProvider: Decodable, GraphQLObject {
    @Ignore
    var id: Int

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

extension StreamingProvider: TMDBNode {
    enum Error: Swift.Error {
        case streamingProviderNotFound(id: Int)
    }

    static var namespace: ID.Namespace {
        return .stremingProvider
    }

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.findStreamingProvider(id: id, locale: nil).flatMap { node in
            guard let node = node else {
                return viewerContext.countries().flatMap { countries in
                    return viewerContext.findStreamingProvider(id: id, locales: countries.map(\.locale))
                }
            }
            return viewerContext.request.eventLoop.future(node)
        }
    }
}

extension MovieDB.ViewerContext {

    fileprivate func findStreamingProvider<C : Collection>(id: Int, locales: C) -> EventLoopFuture<TMDBNode> where C.Element == String {
        guard let first = locales.first else { return request.eventLoop.future(error: StreamingProvider.Error.streamingProviderNotFound(id: id)) }
        return findStreamingProvider(id: id, locale: first).flatMap { node in
            guard let node = node else {
                return self.findStreamingProvider(id: id, locales: locales.dropFirst())
            }
            return self.request.eventLoop.future(node)
        }
    }

    fileprivate func findStreamingProvider(id: Int, locale: String?) -> EventLoopFuture<TMDBNode?> {
        return streamingProviders(locale: locale).map { $0?.first { $0.id == id } }
    }

}
