
import Foundation
import GraphZahl
import NIO

enum MovieDB : GraphQLSchema {
    typealias ViewerContext = Client

    class Query: QueryType {
        let client: Client

        var movies: Movies {
            return Movies(client: client)
        }

        var people: People {
            return People(client: client)
        }

        var tv: TV {
            return TV(client: client)
        }

        func search(term: String) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return client.get(at: "search", "multi", query: ["query" : term])
        }

        func trending(timeWindow: TimeWindow = .day) -> EventLoopFuture<Paging<MovieOrTVOrPeople>> {
            return client.get(at: "trending", "all", .constant(timeWindow.rawValue))
        }

        required init(viewerContext client: Client) {
            self.client = client
        }
    }
}
