
import Foundation
import GraphZahl
import NIO

class BasicPerson: Decodable, GraphQLObject {
    let profilePicture: Image<ProfileSize>?
    let id: Int
    let name: String

    private enum CodingKeys: String, CodingKey {
        case profilePicture = "profile_path"
        case id, name
    }

    var credits: PersonCredits {
        return PersonCredits(id: id)
    }

    func details(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<DetailedPerson> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)))
    }

    func images(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[DetailImage<ProfileSize>]> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "images").map { (wrapper: PersonImages) in wrapper.profiles }
    }

    func externalIds(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<ExternalIDS> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "external_ids")
    }

    func translations(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[Translation<TranslatedPersonInfo>]> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }

    func taggedImages(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<Paging<TaggedImage>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "tagged_images")
    }
}

extension BasicPerson: TMDBNode {
    static let namespace: ID.Namespace = .person

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.person(id: id).map { $0 }
    }
}

extension Client {

    func person(id: Int) -> EventLoopFuture<DetailedPerson> {
        return get(at: "person", .constant(String(id)))
    }

}
