
import Foundation
import GraphZahl

enum AnyImage: Decodable {
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

extension AnyImage: DelegatedOutputResolvable {
    typealias Resolvable = Union5<DetailImage<BackdropSize>, DetailImage<PosterSize>, DetailImage<ProfileSize>, DetailImage<StillSize>, DetailImage<LogoSize>>

    func resolve() throws -> Resolvable {
        switch self {
        case .backdrop(let image):
            return .a(image)
        case .poster(let image):
            return .b(image)
        case .profile(let image):
            return .c(image)
        case .still(let image):
            return .d(image)
        case .logo(let image):
            return .e(image)
        }
    }
}
