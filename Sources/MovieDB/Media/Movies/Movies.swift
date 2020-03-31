
import Foundation
import GraphZahl
import NIO

class Movies: GraphQLObject {
    let client: Client

    init(client: Client) {
        self.client = client
    }

    func search(term: String) -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "search", "movie", query: ["query" : term])
    }

    func movie(id: Int) -> EventLoopFuture<DetailedMovie> {
        return client.get(at: "movie", .constant(String(id)))
    }

    func upcoming() -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", "upcoming")
    }

    func topRated() -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", "top_rated")
    }

    func popular() -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", "popular")
    }

    func nowPlaying() -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "movie", "now_playing")
    }
}
