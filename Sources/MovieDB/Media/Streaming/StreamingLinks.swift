
import Foundation
import GraphZahl

final class StreamingLinks: Decodable, GraphQLObject {
    enum CodingKeys: String, CodingKey {
        case standardWeb = "standard_web"
        case deeplinkWeb = "deeplink_web"
        case androidTV = "deeplink_android_tv"
        case tvOS = "deeplink_tvos"
        case fireTV = "deeplink_fire_tv"
    }

    let web: URL?
    let androidTV: URL?
    let tvOS: URL?
    let fireTV: URL?

    init(web: URL?, androidTV: URL?, tvOS: URL?, fireTV: URL?) {
        self.web = web
        self.androidTV = androidTV
        self.tvOS = tvOS
        self.fireTV = fireTV
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let web: URL?
        if let deeplink = try container.decodeIfPresent(URL.self, forKey: .deeplinkWeb) {
            web = deeplink
        } else if let standard = try container.decodeIfPresent(URL.self, forKey: .standardWeb) {
            web = standard
        } else {
            web = nil
        }

        self.init(web: web,
                  androidTV: try container.decodeIfPresent(URL.self, forKey: .androidTV),
                  tvOS: try container.decodeIfPresent(URL.self, forKey: .tvOS),
                  fireTV: try container.decodeIfPresent(URL.self, forKey: .fireTV))
    }
}

