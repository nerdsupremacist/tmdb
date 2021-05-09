
import Foundation
import GraphZahl
import NIO

class People: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<Paging<PersonListResult>> {
        return viewerContext.tmdb.get(at: "search", "person", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<PersonListResult>> {
        return viewerContext.tmdb.get(at: "trending", "person", .constant(timeWindow.rawValue))
    }

    func person(id: ID) -> EventLoopFuture<DetailedPerson> {
        return id.idValue(for: .person, eventLoop: viewerContext.request.eventLoop).flatMap { self.viewerContext.tmdb.person(id: $0) }
    }

    func popular() -> EventLoopFuture<Paging<PersonListResult>> {
        return viewerContext.tmdb.get(at: "person", "popular")
    }
}
