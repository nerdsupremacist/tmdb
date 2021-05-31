
import Foundation
import Vapor
import NIO
import GraphZahl

class Genres: GraphQLObject {
    let viewerContext: MovieDB.ViewerContext

    init(viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
    }

    func genre(id: ID) -> EventLoopFuture<Genre> {
        return id.idValue(for: .genre, eventLoop: viewerContext.request.eventLoop).flatMap { id in
            return self.viewerContext.tmdb.genre(id: id)
        }
    }

    func all() -> EventLoopFuture<AnyFixedPageSizeIndexedConnection<Genre>> {
        let movies = viewerContext.tmdb.get(at: "genre", "movie", "list", type: GenresList.self).map(\.genres)
        let tv = viewerContext.tmdb.get(at: "genre", "tv", "list", type: GenresList.self).map(\.genres)

        return movies
            .and(tv)
            .map { movies, tv in
                var values: [Genre] = movies
                let ids: Set<Int> = Set(movies.map(\.id))
                for genre in tv {
                    if !ids.contains(genre.id) {
                        values.append(genre)
                    }
                }
                return values.asConnection(with: "genres")
            }
    }
}

private struct GenresList: Decodable {
    let genres: [Genre]
}
