
import Foundation
import GraphZahl
import NIO

class BasicPerson: Decodable, GraphQLObject {
    let profilePicture: Image<ProfileSize>?

    @Ignore
    var id: Int

    let name: String

    private enum CodingKeys: String, CodingKey {
        case profilePicture = "profile_path"
        case id, name
    }

    var credits: PersonCredits {
        return PersonCredits(id: id)
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

    func taggedImages(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<AnyFixedPageSizeIndexedConnection<TaggedImage<OutputTypeNamespace>>> {
        return viewerContext.tmdb.get(at: "person", .constant(String(id)), "tagged_images").map { (images: Paging<TaggedImage<DecodableTypeNamespace>>) in
            return images.map { $0.output(viewerContext: viewerContext) }
        }
    }
}
