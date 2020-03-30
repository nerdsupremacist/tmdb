
import Foundation
import GraphZahl

class DetailImage<Size : GraphQLEnum>: Decodable, GraphQLObject {
    static var concreteTypeName: String {
        return "\(Size.concreteTypeName)DetailImage"
    }

    let aspectRatio: Double
    let image: Image<Size>
    let height: Int
    let iso639_1: String?
    let voteAverage: Double
    let voteCount, width: Int

    private enum CodingKeys: String, CodingKey {
        case aspectRatio = "aspect_ratio"
        case image = "file_path"
        case height
        case iso639_1 = "iso_639_1"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case width
    }
}
