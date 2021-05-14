
import Foundation
import NIO
import GraphZahl
import Vapor
import Cache

class Person: GraphQLObject, Node {
    @Inline
    var person: BasicPerson

    @LazyInline
    var medium: MediumPerson

    @LazyInline
    var details: DetailedPerson

    @Ignore
    var internalKnownFor: [MovieOrTV<DecodableTypeNamespace>]?

    init(person: BasicPerson, viewerContext: MovieDB.ViewerContext) {
        self.person = person
        self._medium = LazyInline { viewerContext.tmdb.person(id: person.id).map { $0 } }
        self._details = LazyInline { viewerContext.tmdb.person(id: person.id) }
        self.internalKnownFor = nil
    }

    init(medium: MediumPerson, viewerContext: MovieDB.ViewerContext) {
        self.person = medium
        self._medium = LazyInline { viewerContext.request.eventLoop.future(medium) }
        self._details = LazyInline { viewerContext.tmdb.person(id: medium.id) }
        self.internalKnownFor = nil
    }

    init(result: PersonListResult, viewerContext: MovieDB.ViewerContext) {
        self.person = result
        self._medium = LazyInline { viewerContext.request.eventLoop.future(result) }
        self._details = LazyInline { viewerContext.tmdb.person(id: result.id) }
        self.internalKnownFor = result.knownFor
    }

    init(details: DetailedPerson, viewerContext: MovieDB.ViewerContext) {
        self.person = details
        self._medium = LazyInline { viewerContext.request.eventLoop.future(details) }
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
        self.internalKnownFor = nil
    }

    func knownFor(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[MovieOrTV<OutputTypeNamespace>]> {
        if let knownFor = internalKnownFor {
            return viewerContext.request.eventLoop.future(knownFor.map { $0.output(viewerContext: viewerContext) })
        }

        return viewerContext.tmdb.get(at: "search", "person", query: ["query" : person.name], type: Page<PersonListResult>.self).map { page in
            return page.results.first { $0.id == self.person.id }?.knownFor.map { $0.output(viewerContext: viewerContext) } ?? []
        }
    }
}

extension Person: TMDBNode {
    static let namespace: ID.Namespace = .person

    var id: Int {
        return person.id
    }

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.person(id: id).map { Person(details: $0, viewerContext: viewerContext) }
    }
}

extension Client {

    func person(id: Int) -> EventLoopFuture<DetailedPerson> {
        return get(at: "person", .constant(String(id)))
    }

}

extension Person {
    typealias Connection = AnyFixedPageSizeIndexedConnection<Person>
}

extension MovieDB.ViewerContext {
    func people(at path: PathComponent..., query: [String : String] = [:], expiry: Expiry = .minutes(30)) -> EventLoopFuture<Person.Connection> {
        return tmdb.get(at: path, query: query, expiry: expiry, type: Paging<PersonListResult>.self).map { paging in
            return paging.map { Person(result: $0, viewerContext: self) }
        }
    }
}
