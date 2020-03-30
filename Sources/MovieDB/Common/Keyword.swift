
import Foundation
import GraphZahl

class Keyword: Decodable, GraphQLObject {
    let id: Int
    let name: String
}

class Keywords: Decodable {
    let keywords: [Keyword]
}
