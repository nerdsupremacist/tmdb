
import Foundation
import GraphZahl

class TaggedImage: Decodable, GraphQLObject {
    private enum CodingKeys: String, CodingKey {
        case type = "media_type"
        case media
    }

    let image: AnyImage
    let media: MovieOrTV

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(MediaType.self, forKey: .type) {
        case .movie:
            media = .movie(try container.decode(MovieResult.self, forKey: .media))
        case .tv:
            media = .tv(try container.decode(TVShowResult.self, forKey: .media))
        default:
            fatalError()
        }

        image = try AnyImage(from: decoder)
    }
}
