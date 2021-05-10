
import Foundation
import GraphZahl

final class FromExternalIds<Namespace: TypeNamespace>: GraphQLObject {
    static var concreteTypeName: String {
        return "FromExternalIds"
    }

    let movies: [Namespace.MovieType]
    let people: [Namespace.PersonType]
    let tv: [Namespace.TVShowType]

    init(movies: [Namespace.MovieType], people: [Namespace.PersonType], tv: [Namespace.TVShowType]) {
        self.movies = movies
        self.people = people
        self.tv = tv
    }
}

extension FromExternalIds: Decodable where Namespace.MovieType: Decodable, Namespace.TVShowType: Decodable, Namespace.PersonType: Decodable {
    private enum CodingKeys: String, CodingKey {
        case movies = "movie_results"
        case people = "person_results"
        case tv = "tv_results"
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(movies: try container.decode([Namespace.MovieType].self, forKey: .movies),
                  people: try container.decode([Namespace.PersonType].self, forKey: .people),
                  tv: try container.decode([Namespace.TVShowType].self, forKey: .tv))
    }
}

extension FromExternalIds {

    func output(viewerContext: MovieDB.ViewerContext) -> FromExternalIds<OutputTypeNamespace> {
        return FromExternalIds<OutputTypeNamespace>(movies: movies.map { Namespace.movie(from: $0, viewerContext: viewerContext) },
                                                    people: people.map { Namespace.person(from: $0, viewerContext: viewerContext) },
                                                    tv: tv.map { Namespace.show(from: $0, viewerContext: viewerContext) })
    }

}
