
import Foundation
import GraphZahl

class FromExternalIds: Decodable, GraphQLObject {
    private enum CodingKeys: String, CodingKey {
        case movies = "movie_results"
        case people = "person_results"
        case tv = "tv_results"
    }

    let movies: [Movie]
    let people: [PersonListResult]
    let tv: [TVShow]
}
