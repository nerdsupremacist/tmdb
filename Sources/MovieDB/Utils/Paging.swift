
import Foundation
import GraphZahl
import Vapor

private struct PagingIdentifier: Hashable {
    let path: String
    let query: [String : String]
}

struct Paging<Node: Decodable & OutputResolvable & ConcreteResolvable>: FixedPageSizeIndexedConnection {
    let client: Client
    let first: Page<Node>
    let path: [PathComponent]
    let query: [String : String]

    var identifier: some Hashable {
        return PagingIdentifier(path: path.map { $0.description }.joined(separator: "/"), query: query)
    }

    func totalCount(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return eventLoop.future(first.totalResults)
    }

    func pageSize(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return eventLoop.future(first.results.count)
    }

    func page(at index: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<[Node?]> {
        return fetch(page: index, eventLoop: eventLoop).map { $0.results.map(Optional.some) }
    }

    private func fetch(page: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<Page<Node>> {
        if page == 0 {
            return eventLoop.future(first)
        }
        let query = self.query.merging(["page" : String(page + 1)]) { $1 }
        return client.get(at: path, query: query, type: Page<Node>.self)
    }
}

struct AnyFixedPageSizeIndexedConnection<Node : OutputResolvable & ConcreteResolvable>: FixedPageSizeIndexedConnection {
    typealias Node = Node
    typealias Identifier = AnyHashable

    let identifier: AnyHashable
    let _totalCount: (EventLoopGroup) -> EventLoopFuture<Int>
    let _pageSize: (EventLoopGroup) -> EventLoopFuture<Int>
    let _page: (Int, EventLoopGroup) -> EventLoopFuture<[Node?]>

    init<C : FixedPageSizeIndexedConnection>(_ c: C) where C.Node == Node {
        self.identifier = AnyHashable(c.identifier)
        _totalCount = { c.totalCount(eventLoop: $0) }
        _pageSize = { c.pageSize(eventLoop: $0) }
        _page = { c.page(at: $0, eventLoop: $1) }
    }

    func totalCount(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return _totalCount(eventLoop)
    }

    func pageSize(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return _pageSize(eventLoop)
    }

    func page(at index: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<[Node?]> {
        return _page(index, eventLoop)
    }
}

extension FixedPageSizeIndexedConnection {

    func map<T : OutputResolvable & ConcreteResolvable>(_ transform: @escaping (Node) -> T) -> AnyFixedPageSizeIndexedConnection<T> {
        return AnyFixedPageSizeIndexedConnection(MappedFixedPageSizeIndexedConnection(prev: self, transform: transform))
    }

}

struct MappedFixedPageSizeIndexedConnection<
    Node: OutputResolvable & ConcreteResolvable, Prev: FixedPageSizeIndexedConnection
>: FixedPageSizeIndexedConnection {

    let prev: Prev
    let transform: (Prev.Node) -> Node

    var identifier: some Hashable {
        return prev.identifier
    }

    func totalCount(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return prev.totalCount(eventLoop: eventLoop)
    }

    func pageSize(eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return prev.pageSize(eventLoop: eventLoop)
    }

    func page(at index: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<[Node?]> {
        return prev.page(at: index, eventLoop: eventLoop).map { $0.map { $0.map(self.transform) } }
    }
}

struct Page<T: Decodable>: Decodable {
    private enum CodingKeys: String, CodingKey {
        case results, page
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }

    let results: [T]
    let page, totalResults: Int
    let totalPages: Int
}
