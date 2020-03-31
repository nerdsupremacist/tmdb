
import Foundation
import GraphZahl

class PersonImages: Decodable, GraphQLObject {
    let profiles: [DetailImage<ProfileSize>]
}
