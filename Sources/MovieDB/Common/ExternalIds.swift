
import Foundation
import GraphZahl
import NIO

class ExternalIDS: Decodable, GraphQLObject {
    let imdb, facebook, instagram, twitter: String?

    private enum CodingKeys: String, CodingKey {
        case imdb = "imdb_id"
        case facebook = "facebook_id"
        case instagram = "instagram_id"
        case twitter = "twitter_id"
    }
}

class FullExternalIDS: GraphQLObject {
    let tmdb: Int

    @LazyInlineAsInterface
    var decoded: ExternalIDS

    init(id tmdb: Int, load: @escaping (Int) -> EventLoopFuture<ExternalIDS>) {
        self.tmdb = tmdb
        self._decoded = LazyInlineAsInterface { load(tmdb) }
    }
}

extension FullExternalIDS {

    static func movie(id: Int, viewerContext: MovieDB.ViewerContext) -> FullExternalIDS {
        return FullExternalIDS(id: id) { viewerContext.tmdb.get(at: "movie", .constant(String($0)), "external_ids") }
    }

    static func person(id: Int, viewerContext: MovieDB.ViewerContext) -> FullExternalIDS {
        return FullExternalIDS(id: id) { viewerContext.tmdb.get(at: "person", .constant(String($0)), "external_ids") }
    }

    static func show(id: Int, viewerContext: MovieDB.ViewerContext) -> FullExternalIDS {
        return FullExternalIDS(id: id) { viewerContext.tmdb.get(at: "tv", .constant(String($0)), "external_ids") }
    }

}
