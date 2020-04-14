
import Foundation
import GraphZahl
import NIO
import GraphQL
import ContextKit

enum MediaType: String, Codable {
    case movie
    case tv
    case person
}

class MovieResult: Movie { }

class TVShowResult: TVShow { }

enum MovieOrTV: Decodable, GraphQLUnion {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    case movie(MovieResult)
    case tv(TVShowResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            self = .movie(try MovieResult(from: decoder))
        case .tv:
            self = .tv(try TVShowResult(from: decoder))
        default:
            fatalError()
        }
    }
}

enum MovieOrTVOrPeople: Decodable, GraphQLUnion {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    case movie(MovieResult)
    case tv(TVShowResult)
    case person(PersonListResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            self = .movie(try MovieResult(from: decoder))
        case .tv:
            self = .tv(try TVShowResult(from: decoder))
        case .person:
            self = .person(try PersonListResult(from: decoder))
        }
    }
}
