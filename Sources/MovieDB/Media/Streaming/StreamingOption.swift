
import Foundation
import GraphZahl
import NIO

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

    func provider(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<StreamingProvider?> {
        return viewerContext.streamingProviders().map { $0?.first(where: { $0.id == self.providerID }) }
    }
}
