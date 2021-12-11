
import Foundation
import NIO
import GraphZahl

class Streaming: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func myCountry() -> EventLoopFuture<StreamingCountry?> {
        return viewerContext.locale(locale: nil).flatMap { locale in
            guard let locale = locale?.lowercased() else { return self.viewerContext.request.eventLoop.future(nil) }
            return self.viewerContext.countries().map { $0.first { $0.locale.lowercased() == locale } }
        }
    }

    func countries() -> EventLoopFuture<[StreamingCountry]> {
        return viewerContext.countries()
    }

    func providers(country: ID?) -> EventLoopFuture<[StreamingProvider]> {
        let locale: EventLoopFuture<String?> = country?
            .idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop)
            .map(Optional.some) ?? viewerContext.request.eventLoop.future(nil)

        return locale.flatMap { locale in
            return self.viewerContext.streamingProviders(locale: locale).map { $0 ?? [] }
        }
    }

    func allProviders() -> EventLoopFuture<[StreamingProvider]> {
        return viewerContext
            .countries()
            .flatMap { countries in
                let providers = countries.map { self.viewerContext.streamingProviders(locale: $0.locale).map { $0 ?? [] } }
                return self.viewerContext.request.eventLoop.flatten(providers).map { $0.flatMap { $0 } }
            }
            .map { (allProviders: [StreamingProvider]) in
                var ids: Set<Int> = []
                var providers: [StreamingProvider] = []
                for provider in allProviders {
                    if !ids.contains(provider.id) {
                        providers.append(provider)
                        ids.formUnion([provider.id])
                    }
                }
                return providers
            }
    }
}
