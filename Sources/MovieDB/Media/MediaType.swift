
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

enum MovieOrTV: Decodable {
    enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    case movie(MovieResult)
    case tv(TVShowResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieOrTV.CodingKeys.self)
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

enum MovieOrTVOrPeople: Decodable {
    enum CodingKeys: String, CodingKey {
        case type = "media_type"
    }

    case movie(MovieResult)
    case tv(TVShowResult)
    case person(PersonListResult)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieOrTVOrPeople.CodingKeys.self)
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

extension MovieOrTV: DelegatedOutputResolvable {

    func resolve() throws -> Union2<MovieResult, TVShowResult> {
        switch self {
        case .movie(let movie):
            return .a(movie)
        case .tv(let show):
            return .b(show)
        }
    }

}

extension MovieOrTVOrPeople: DelegatedOutputResolvable {

    func resolve() throws -> Union3<MovieResult, TVShowResult, PersonListResult> {
        switch self {
        case .movie(let movie):
            return .a(movie)
        case .tv(let show):
            return .b(show)
        case .person(let person):
            return .c(person)
        }
    }

}

protocol DelegatedOutputResolvable: OutputResolvable, ConcreteResolvable {
    associatedtype Resolvable: OutputResolvable & ConcreteResolvable
    func resolve() throws -> Resolvable
}

extension DelegatedOutputResolvable {

    static var additionalArguments: [String : InputResolvable.Type] {
        return Resolvable.additionalArguments
    }

    static var concreteTypeName: String {
        return Resolvable.concreteTypeName
    }

    static func reference(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.reference(for: Resolvable.self)
    }

    static func resolve(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.resolve(type: Resolvable.self)
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> EventLoopFuture<Any?> {
        return try resolve().resolve(source: source, arguments: arguments, context: context, eventLoop: eventLoop)
    }

}
