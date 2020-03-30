
import Foundation
import GraphZahl

class Review: Decodable, GraphQLObject {
    let id, author, content: String
    let url: String
}
