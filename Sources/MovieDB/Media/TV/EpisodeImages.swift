
import Foundation
import GraphZahl

class EpisodeImages: Decodable, GraphQLObject {
    let stills: [DetailImage<StillSize>]
}
