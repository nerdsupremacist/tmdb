
import Foundation
import GraphZahl
import NIO

class TV: GraphQLObject {
    let client: Client

    init(client: Client) {
        self.client = client
    }

    func search(term: String) -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "search", "tv", query: ["query" : term])
    }

    func show(id: String) -> EventLoopFuture<DetailedTVShow> {
        return client.get(at: "tv", .constant(id))
    }

    func upcoming() -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", "upcoming")
    }

    func topRated() -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", "top_rated")
    }

    func popular() -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", "popular")
    }

    func onTheAir() -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", "on_the_air")
    }

    func airingToday() -> EventLoopFuture<Paging<TVShow>> {
        return client.get(at: "tv", "airing_today")
    }
}
