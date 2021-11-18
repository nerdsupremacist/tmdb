
import Foundation
import NIO
import GraphZahl
import Vapor
import Cache

class TVShow: GraphQLObject, Node {
    @Inline
    var show: BasicTVShow

    @LazyInline
    var details: DetailedTVShow

    @InlineAsInterface
    var streamable: Streamable

    init(show: BasicTVShow, viewerContext: MovieDB.ViewerContext) {
        self.show = show
        self._details = LazyInline { viewerContext.tmdb.show(id: show.id) }
        self.streamable = Streamable { $0.streamingOptions(id: show.id, name: show.name, contentType: .show, locale: $1) }
    }

    init(details: DetailedTVShow, viewerContext: MovieDB.ViewerContext) {
        self.show = details
        self._details = LazyInline { viewerContext.request.eventLoop.future(details) }
        self.streamable = Streamable { $0.streamingOptions(id: details.id, name: details.name, contentType: .show, locale: $1) }
    }
}

extension TVShow: TMDBNode {
    static let namespace: ID.Namespace = .show

    var id: Int {
        return show.id
    }

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.show(id: id).map { TVShow(details: $0, viewerContext: viewerContext) }
    }
}

extension Client {

    func show(id: Int) -> EventLoopFuture<DetailedTVShow> {
        return get(at: "tv", .constant(String(id)))
    }

}

extension TVShow {
    typealias Connection = AnyFixedPageSizeIndexedConnection<TVShow>
}

extension MovieDB.ViewerContext {
    func shows(at path: PathComponent..., query: [String : String] = [:], expiry: Expiry = .minutes(30)) -> EventLoopFuture<TVShow.Connection> {
        return tmdb.get(at: path, query: query, expiry: expiry, type: Paging<BasicTVShow>.self).map { paging in
            return paging.map { TVShow(show: $0, viewerContext: self) }
        }
    }
}
