
import Foundation
import GraphZahl
import NIO

class People: GraphQLObject {
    let client: Client

    init(client: Client) {
        self.client = client
    }

    func search(term: String) -> EventLoopFuture<Paging<PersonListResult>> {
        return client.get(at: "search", "person", query: ["query" : term])
    }

    func person(id: String) -> EventLoopFuture<DetailedPerson> {
        return client.get(at: "person", .constant(id))
    }

    func popular() -> EventLoopFuture<Paging<PersonListResult>> {
        return client.get(at: "person", "popular")
    }
}
