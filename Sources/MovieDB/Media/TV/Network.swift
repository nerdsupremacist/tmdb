
import Foundation
import GraphZahl

class Network: Decodable, GraphQLObject {
    let name: String
    let id: Int
    let logo: Image<LogoSize>?
    let originCountry: String

    private enum CodingKeys: String, CodingKey {
        case name, id
        case logo = "logo_path"
        case originCountry = "origin_country"
    }
}
