
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

enum MovieOrTV<Namespace: TypeNamespace>: GraphQLUnion {
    static var concreteTypeName: String {
        return "MovieOrTV"
    }

    case movie(Namespace.MovieType)
    case tv(Namespace.TVShowType)
}

extension MovieOrTV: Decodable where Namespace.MovieType: Decodable, Namespace.TVShowType: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            self = .movie(try Namespace.MovieType(from: decoder))
        case .tv:
            self = .tv(try Namespace.TVShowType(from: decoder))
        default:
            fatalError()
        }
    }
}

extension MovieOrTV {

    func output(viewerContext: MovieDB.ViewerContext) -> MovieOrTV<OutputTypeNamespace> {
        switch self {
        case .movie(let movie):
            return .movie(Namespace.movie(from: movie, viewerContext: viewerContext))
        case .tv(let show):
            return .tv(Namespace.show(from: show, viewerContext: viewerContext))
        }
    }

}

enum MovieOrTVOrPeople<Namespace: TypeNamespace>: GraphQLUnion {
    static var concreteTypeName: String {
        return "MovieOrTVOrPeople"
    }

    case movie(Namespace.MovieType)
    case tv(Namespace.TVShowType)
    case person(Namespace.PersonType)
}

extension MovieOrTVOrPeople: Decodable where Namespace.MovieType: Decodable, Namespace.TVShowType: Decodable, Namespace.PersonType: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            self = .movie(try Namespace.MovieType(from: decoder))
        case .tv:
            self = .tv(try Namespace.TVShowType(from: decoder))
        default:
            self = .person(try Namespace.PersonType(from: decoder))
        }
    }
}

extension MovieOrTVOrPeople {

    func output(viewerContext: MovieDB.ViewerContext) -> MovieOrTVOrPeople<OutputTypeNamespace> {
        switch self {
        case .movie(let movie):
            return .movie(Namespace.movie(from: movie, viewerContext: viewerContext))
        case .tv(let show):
            return .tv(Namespace.show(from: show, viewerContext: viewerContext))
        case .person(let person):
            return .person(Namespace.person(from: person, viewerContext: viewerContext))
        }
    }

}
