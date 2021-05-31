
import Foundation
import GraphZahl
import NIO

class NestedMovies: GraphQLObject {
    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    @Ignore
    var filter: String

    @Ignore
    var id: Int

    private init(filter: String, id: Int) {
        self.filter = filter
        self.id = id
    }

    func latest(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        let today = NestedMovies.formatter.string(from: Date())
        return viewerContext.movies(at: "discover", "movie",
                                    query: [
                                        filter : String(id),
                                        "sort_by" : "release_date.desc",
                                        "release_date.lte" : today,
                                    ])
    }

    func popular(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "discover", "movie",
                                    query: [
                                        filter : String(id),
                                        "sort_by" : "popularity.desc",
                                    ])
    }

    func topRated(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Movie.Connection> {
        return viewerContext.movies(at: "discover", "movie",
                                    query: [
                                        filter : String(id),
                                        "sort_by" : "vote_average.desc",
                                        "vote_count.gte": "100",
                                    ])
    }
}

extension NestedMovies {

    static func genre(id: Int) -> NestedMovies {
        return NestedMovies(filter: "with_genres", id: id)
    }

    static func keyword(id: Int) -> NestedMovies {
        return NestedMovies(filter: "with_keywords", id: id)
    }

    static func productionCompany(id: Int) -> NestedMovies {
        return NestedMovies(filter: "with_companies", id: id)
    }

}
