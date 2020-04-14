
import Foundation
import GraphZahl

enum AnyImage: Decodable, GraphQLUnion {
    private enum CodingKeys: String, CodingKey {
        case imageType = "image_type"
    }

    case backdrop(DetailImage<BackdropSize>)
    case poster(DetailImage<PosterSize>)
    case profile(DetailImage<ProfileSize>)
    case still(DetailImage<StillSize>)
    case logo(DetailImage<LogoSize>)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(ImageType.self, forKey: .imageType) {
        case .backdrop:
            self = .backdrop(try DetailImage<BackdropSize>(from: decoder))
        case .poster:
            self = .poster(try DetailImage<PosterSize>(from: decoder))
        case .profile:
            self = .profile(try DetailImage<ProfileSize>(from: decoder))
        case .still:
            self = .still(try DetailImage<StillSize>(from: decoder))
        case .logo:
            self = .logo(try DetailImage<LogoSize>(from: decoder))
        }
    }
}
