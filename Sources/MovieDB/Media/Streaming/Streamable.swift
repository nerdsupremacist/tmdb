
import Foundation
import GraphZahl
import NIO

class Streamable: GraphQLObject {
    let links: (MovieDB.ViewerContext, String?) -> EventLoopFuture<[StreamingOption]?>

    init(links: @escaping (MovieDB.ViewerContext, String?) -> EventLoopFuture<[StreamingOption]?>) {
        self.links = links
    }

    func streamingOptions(viewerContext: MovieDB.ViewerContext, country: ID?) -> EventLoopFuture<[StreamingOption]?> {
        let locale: EventLoopFuture<String?> = country?
            .idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop)
            .map(Optional.some) ?? viewerContext.request.eventLoop.future(nil)

        return locale.flatMap { locale in
            return self.links(viewerContext, locale)
        }
    }

    func searchStreamingOptions(viewerContext: MovieDB.ViewerContext,
                                providers: [ID],
                                countries: [ID]?) -> EventLoopFuture<[StreamingResultForProvideer]> {

        return viewerContext.searchStreamingOptions(providers: providers, countries: countries) { self.links(viewerContext, $0) }
    }
}
