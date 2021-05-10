
import Foundation
import GraphZahl
import NIO

class People: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func search(term: String) -> EventLoopFuture<Person.Connection> {
        return viewerContext.people(at: "search", "person", query: ["query" : term])
    }

    func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Person.Connection> {
        return viewerContext.people(at: "trending", "person", .constant(timeWindow.rawValue))
    }

    func person(id: ID) -> EventLoopFuture<Person> {
        return id
            .idValue(for: .person, eventLoop: viewerContext.request.eventLoop)
            .flatMap { self.viewerContext.tmdb.person(id: $0) }
            .map { Person(details: $0, viewerContext: self.viewerContext) }
    }

    func popular() -> EventLoopFuture<Person.Connection> {
        return viewerContext.people(at: "person", "popular")
    }
}
