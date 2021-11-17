
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
}
