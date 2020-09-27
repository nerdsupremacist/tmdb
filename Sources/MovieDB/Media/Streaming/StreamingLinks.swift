
import Foundation
import GraphZahl

class StreamingLinks: Decodable, GraphQLObject {
    enum CodingKeys: String, CodingKey {
        case web = "standard_web"
        case androidTV = "deeplink_android_tv"
        case tvOS = "deeplink_tvos"
        case fireTV = "deeplink_fire_tv"
    }

    let web: URL
    let androidTV: URL?
    let tvOS: URL?
    let fireTV: URL?

    init(web: URL, androidTV: URL?, tvOS: URL?, fireTV: URL?) {
        self.web = web
        self.androidTV = androidTV
        self.tvOS = tvOS
        self.fireTV = fireTV
    }
}
