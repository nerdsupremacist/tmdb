
import Foundation
import Vapor
import NIO

class Client {
    enum Error: Swift.Error {
        case emptyResponse
        case failedDecoding
        case invalidURL(URL)
    }

    let base: URL
    let imagesBase: URL
    let apiKey: String

    var eventLoop: EventLoopGroup {
        return httpClient.eventLoopGroup
    }

    private let httpClient: HTTPClient

    init(base: URL, imagesBase: URL, apiKey: String, httpClient: HTTPClient) {
        self.base = base
        self.imagesBase = imagesBase
        self.apiKey = apiKey
        self.httpClient = httpClient
    }

    deinit {
        try! httpClient.syncShutdown()
    }

    func get<T: Decodable>(at path: [PathComponent], query: [String : String] = [:], type: T.Type = T.self) -> EventLoopFuture<T> {
        let composed = path.reduce(base) { $0.appendingPathComponent($1.description) }

        guard var components = URLComponents(url: composed, resolvingAgainstBaseURL: true) else {
            return httpClient.eventLoopGroup.future(error: Error.invalidURL(composed))
        }

        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) } + [URLQueryItem(name: "api_key", value: apiKey)]

        guard let url = components.url else { return httpClient.eventLoopGroup.future(error: Error.invalidURL(composed)) }
        return httpClient.get(url: url.absoluteString).decode(type: type)
    }

    func get<T: Decodable>(at path: PathComponent..., query: [String : String] = [:], type: T.Type = T.self) -> EventLoopFuture<T> {
        return get(at: path, query: query, type: type)
    }

    func get<T: Decodable>(at path: PathComponent..., query: [String : String] = [:]) -> EventLoopFuture<Paging<T>> {
        return get(at: path, query: query, type: Page<T>.self).map { page in
            return Paging(client: self, first: page, path: path, query: query)
        }
    }
}

extension EventLoopFuture where Value == HTTPClient.Response {

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
        return decoder
    }()

    func decode<T: Decodable>(type: T.Type = T.self) -> EventLoopFuture<T> {
        return flatMapThrowing { response in
            guard let buffer = response.body else {
                throw Client.Error.emptyResponse
            }

            let length = buffer.readableBytes
            do {
                guard let data = try buffer.getJSONDecodable(type, decoder: Self.decoder, at: 0, length: length) else {
                    throw Client.Error.failedDecoding
                }

                return data
            } catch {
                print(error)
                throw error
            }
        }
    }

}
