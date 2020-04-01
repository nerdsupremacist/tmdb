
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

    func trending(timeWindow: TimeWindow?) -> EventLoopFuture<Paging<TVShow>> {
        let timeWindow = timeWindow ?? .day
        return client.get(at: "trending", "tv", .constant(timeWindow.rawValue))
    }

    func show(id: Int) -> EventLoopFuture<DetailedTVShow> {
        return client.get(at: "tv", .constant(String(id)))
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
