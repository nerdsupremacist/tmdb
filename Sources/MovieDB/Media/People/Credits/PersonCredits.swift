
import Foundation
import GraphZahl
import NIO

class PersonCredits: GraphQLObject {
    @Ignore
    var id: Int

    init(id: Int) {
        self.id = id
    }

    func all(client: Client) -> EventLoopFuture<Credits<MovieOrTV>> {
        return client.get(at: "person", .constant(String(id)), "combined_credits")
    }

    func movies(client: Client) -> EventLoopFuture<Credits<Movie>> {
        return client.get(at: "person", .constant(String(id)), "movie_credits")
    }

    func tv(client: Client) -> EventLoopFuture<Credits<TVShow>> {
        return client.get(at: "person", .constant(String(id)), "tv_credits")
    }
}
