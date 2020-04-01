
import Foundation
import GraphZahl
import NIO

class Keyword: Decodable, GraphQLObject {
    let id: Int
    let name: String

    func movies(client: Client) -> EventLoopFuture<Paging<Movie>> {
        return client.get(at: "keyword", .constant(String(id)), "movies")
    }
}

class Keywords: Decodable {
    let keywords: [Keyword]
}
