
import Foundation
import GraphZahl

protocol TypeNamespace {
    associatedtype MovieType: GraphQLObject
    associatedtype TVShowType: GraphQLObject
    associatedtype PersonType: GraphQLObject

    static func movie(from current: MovieType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.MovieType
    static func show(from current: TVShowType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.TVShowType
    static func person(from current: PersonType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.PersonType
}

extension TypeNamespace where MovieType == OutputTypeNamespace.MovieType {

    static func movie(from current: MovieType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.MovieType {
        return current
    }

}

extension TypeNamespace where TVShowType == OutputTypeNamespace.TVShowType {

    static func show(from current: TVShowType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.TVShowType {
        return current
    }

}

extension TypeNamespace where PersonType == OutputTypeNamespace.PersonType {

    static func person(from current: PersonType, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.PersonType {
        return current
    }

}

enum OutputTypeNamespace: TypeNamespace {
    typealias MovieType = Movie
    typealias TVShowType = TVShow
    typealias PersonType = Person
}

enum DecodableTypeNamespace: TypeNamespace {
    typealias MovieType = BasicMovie
    typealias TVShowType = BasicTVShow
    typealias PersonType = PersonListResult

    static func movie(from current: BasicMovie, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.MovieType {
        return Movie(movie: current, viewerContext: viewerContext)
    }

    static func show(from current: BasicTVShow, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.TVShowType {
        return TVShow(show: current, viewerContext: viewerContext)
    }

    static func person(from current: PersonListResult, viewerContext: MovieDB.ViewerContext) -> OutputTypeNamespace.PersonType {
        return Person(result: current, viewerContext: viewerContext)
    }
}

