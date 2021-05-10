
import Foundation
import GraphZahl
import NIO

class PersonCredits: GraphQLObject {
    @Ignore
    var id: Int

    init(id: Int) {
        self.id = id
    }

    func all(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<MovieOrTV<OutputTypeNamespace>>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "combined_credits").map { (credits: Credits<MovieOrTV<DecodableTypeNamespace>>) in
            return credits.map { $0.output(viewerContext: viewerContext) }
        }
    }

    func movies(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<Movie>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "movie_credits").map { (credits: Credits<BasicMovie>) in
            return credits.map { Movie(movie: $0, viewerContext: viewerContext) }
        }
    }

    func tv(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Credits<TVShow>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "tv_credits").map { (credits: Credits<BasicTVShow>) in
            return credits.map { TVShow(show: $0, viewerContext: viewerContext) }
        }
    }
}
