
import Foundation
import GraphZahl
import NIO
import Vapor

class Network: Decodable, GraphQLObject {
    @Ignore
    var id: Int

    let name: String
    let logo: Image<LogoSize>?
    let originCountry: String

    private enum CodingKeys: String, CodingKey {
        case name, id
        case logo = "logo_path"
        case originCountry = "origin_country"
    }

    var tv: NestedTV {
        return .network(id: id)
    }
}

extension Network: TMDBNode {
    static let namespace: ID.Namespace = .network

    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode> {
        return viewerContext.tmdb.network(id: id).map { $0 }
    }
}

extension Client {

    func network(id: Int) -> EventLoopFuture<Network> {
        return get(at: "network", .constant(String(id)))
    }

}
