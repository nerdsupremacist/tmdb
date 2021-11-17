
import Foundation
import NIO
import GraphZahl

class Streaming: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
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
