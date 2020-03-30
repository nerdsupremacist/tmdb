
import Foundation
import GraphZahl

class MediaImages: Decodable, GraphQLObject {
    let backdrops: [DetailImage<BackdropSize>]
    let posters: [DetailImage<PosterSize>]
}
