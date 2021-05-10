
import Foundation
import GraphZahl

final class TaggedImage<Namespace: TypeNamespace>: GraphQLObject {
    static var concreteTypeName: String {
        return "TaggedImage"
    }

    let image: AnyImage
    let media: MovieOrTV<Namespace>

    internal init(image: AnyImage, media: MovieOrTV<Namespace>) {
        self.image = image
        self.media = media
    }
}

extension TaggedImage: Decodable where Namespace.MovieType: Decodable, Namespace.TVShowType: Decodable {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
        case media
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let media: MovieOrTV<Namespace>
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            media = .movie(try container.decode(Namespace.MovieType.self, forKey: .media))
        case .tv:
            media = .tv(try container.decode(Namespace.TVShowType.self, forKey: .media))
        default:
            fatalError()
        }

        self.init(image: try AnyImage(from: decoder), media: media)
    }
}

extension TaggedImage {

    func output(viewerContext: MovieDB.ViewerContext) -> TaggedImage<OutputTypeNamespace> {
        return TaggedImage<OutputTypeNamespace>(image: image, media: media.output(viewerContext: viewerContext))
    }

}
