
import Foundation
import GraphZahl

class ExternalIDS: Decodable, GraphQLObject {
    let imdb, facebook, instagram, twitter: String?

    private enum CodingKeys: String, CodingKey {
        case imdb = "imdb_id"
        case facebook = "facebook_id"
        case instagram = "instagram_id"
        case twitter = "twitter_id"
    }
}
