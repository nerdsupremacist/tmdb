
import Foundation
import GraphZahl
import NIO

class BasicPerson: Decodable, GraphQLObject {
    let profilePicture: Image<ProfileSize>?
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case profilePicture = "profile_path"
        case id, name
    }

    var credits: PersonCredits {
        return PersonCredits(id: id)
    }

    func details(client: Client) -> EventLoopFuture<DetailedPerson> {
        return client.get(at: "person", .constant(String(id)))
    }

    func images(client: Client) -> EventLoopFuture<[DetailImage<ProfileSize>]> {
        return client.get(at: "person", .constant(String(id)), "images").map { (wrapper: PersonImages) in wrapper.profiles }
    }

    func externalIds(client: Client) -> EventLoopFuture<ExternalIDS> {
        return client.get(at: "person", .constant(String(id)), "external_ids")
    }

    func translations(client: Client) -> EventLoopFuture<[Translation<TranslatedPersonInfo>]> {
        return client.get(at: "person", .constant(String(id)), "translations").map { (wrapper: Translations) in wrapper.translations }
    }
}
