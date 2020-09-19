
import Foundation
import GraphZahl

class StreamingProvider: Decodable, GraphQLObject {
    let id: Int
    let slug, name: String
    let monetizationTypes: [StreamingMonetizationType]
    let iconURL: StreamingProviderIconURL

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name = "clear_name"
        case monetizationTypes = "monetization_types"
        case iconURL = "icon_url"
    }
}
