
import Foundation
import GraphZahl
import Vapor

struct Paging<Node: Decodable & OutputResolvable & ConcreteResolvable>: ContextBasedConnection, ConcreteResolvable {
    struct Context {
        let skipOnFirst: Int
        let skipOnLast: Int
        let pages: ClosedRange<Int>
        let cursors: ClosedRange<Int>
    }

    static var concreteTypeName: String {
        return "\(Node.concreteTypeName)Connection"
    }

    let client: Client
    let first: Page<Node>
    let path: [PathComponent]
    let query: [String : String]

    func context(first: Int?, after: String?, last: Int?, before: String?, eventLoop: EventLoopGroup) -> EventLoopFuture<Context> {
        let perPage = self.first.results.count

        if perPage == 0 {
            return eventLoop.future(Context(skipOnFirst: 0, skipOnLast: 0, pages: 0...0, cursors: 0...0))
        }

        let first = first == nil && last == nil ? perPage : first
        var start = 0
        var end = self.first.totalResults

        if let after = after.flatMap(Int.init) {
            start = max(start, after + 1)
        }

        if let before = before.flatMap(Int.init) {
            end = min(before, end)
        }

        if let first = first {
            end = min(start + first, end)
        }

        if let last = last {
            start = max(start, end - last)
        }

        let firstPage = start / perPage
        let lastPage = (end - 1) / perPage
        let pages = firstPage...lastPage
        let cursors = start...(end - 1)

        let skipFirst = start.quotientAndRemainder(dividingBy: perPage).remainder
        let skipLast = (perPage - end.quotientAndRemainder(dividingBy: perPage).remainder).quotientAndRemainder(dividingBy: perPage).remainder

        return eventLoop.future(Context(skipOnFirst: skipFirst, skipOnLast: skipLast, pages: pages, cursors: cursors))
    }

    private func fetch(page: Int, eventLoop: EventLoopGroup) -> EventLoopFuture<Page<Node>> {
        if page == 0 {
            return eventLoop.future(first)
        }
        let query = self.query.merging(["page" : String(page + 1)]) { $1 }
        return client.get(at: path, query: query, type: Page<Node>.self)
    }

    func totalCount(context: Context, eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return eventLoop.future(first.totalResults)
    }

    func pageInfo(context: Context, eventLoop: EventLoopGroup) -> EventLoopFuture<PageInfo> {
        let hasNextPage: Bool
        let hasPreviousPage: Bool

        switch context.pages.upperBound {
        case ..<(first.totalPages - 1):
            hasNextPage = true
        case first.totalPages - 1:
            hasNextPage = context.skipOnLast > 0
        default:
            hasNextPage = false
        }

        switch context.pages.lowerBound {
        case 1...:
            hasPreviousPage = true
        case 0:
            hasPreviousPage = context.skipOnFirst > 0
        default:
            hasPreviousPage = false
        }

        return eventLoop.future(
            PageInfo(hasNextPage: hasNextPage,
                     hasPreviousPage: hasPreviousPage,
                     startCursor: String(context.cursors.lowerBound),
                     endCursor: String(context.cursors.upperBound))
        )
    }

    func edges(context: Context, eventLoop: EventLoopGroup) -> EventLoopFuture<[StandardEdge<Node>?]?> {
        let futures = context.pages.map { self.fetch(page: $0, eventLoop: eventLoop) }
        return eventLoop
            .next()
            .flatten(futures)
            .map { $0.flatMap { $0.results } }
            .map { $0.dropFirst(context.skipOnFirst).dropLast(context.skipOnLast) }
            .map { $0.enumerated().map { StandardEdge(node: $0.element, cursor: String($0.offset + context.cursors.lowerBound)) } }
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
