
import Foundation
import Vapor
import NIO
import Cache

protocol Authenticator {
    func authenticate(with queryParamters: inout [URLQueryItem])
}

class Client {
    enum Error: Swift.Error {
        case emptyResponse
        case failedDecoding
        case invalidURL(URL)
    }

    struct CacheEntry: Hashable {
        let method: HTTPMethod
        let url: URL
        let body: JSON?
    }

    let base: URL
    let authenticator: Authenticator?
    let cache: MemoryStorage<CacheEntry, Any>?

    var eventLoop: EventLoopGroup {
        return httpClient.eventLoopGroup
    }

    private let httpClient: HTTPClient

    init(base: URL, authenticator: Authenticator? = nil, httpClient: HTTPClient, cache: MemoryStorage<CacheEntry, Any>? = nil) {
        self.base = base
        self.authenticator = authenticator
        self.httpClient = httpClient
        self.cache = cache
    }

    deinit {
        httpClient.shutdown { [httpClient] error in
            _ = httpClient
            guard let error = error else { return }
            print("Error shutting down client \(error)")
        }
    }

    private func request<T: Decodable>(_ method: HTTPMethod,
                                       at path: [PathComponent],
                                       query: [String : String] = [:],
                                       body: JSON? = nil,
                                       expiry: Expiry = .minutes(30),
                                       type: T.Type = T.self) -> EventLoopFuture<T> {

        let composed = path.reduce(base) { $0.appendingPathComponent($1.description) }

        guard var components = URLComponents(url: composed, resolvingAgainstBaseURL: true) else {
            return httpClient.eventLoopGroup.future(error: Error.invalidURL(composed))
        }

        var items = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        authenticator?.authenticate(with: &items)
        components.queryItems = !items.isEmpty ? items : nil

        guard let url = components.url else { return httpClient.eventLoopGroup.future(error: Error.invalidURL(composed)) }
        let entry = CacheEntry(method: method, url: url, body: body)

        if let cached = cache?.nonExpiredObject(entry) as? T {
            return eventLoop.future(cached)
        }

        return httpClient.eventLoopGroup.tryFuture {
            let body = try body.map { body -> HTTPClient.Body in
                let data = try JSONEncoder().encode(body)
                return HTTPClient.Body.data(data)
            }

            var request = try HTTPClient.Request(url: url, method: method, body: body)
            if body != nil {
                request.headers.add(name: .contentType, value: "application/json")
            }

            return httpClient.execute(request: request)
                .decode(type: type)
                .always { [weak cache] result in
                    guard case .success(let response) = result else { return }
                    cache?.setObject(response, forKey: entry, expiry: expiry)
                }
        }
        .flatMap { $0 }
    }

    func get<T: Decodable>(at path: [PathComponent], query: [String : String] = [:], expiry: Expiry = .minutes(30), type: T.Type = T.self) -> EventLoopFuture<T> {
        return request(.GET, at: path, query: query, body: nil, expiry: expiry, type: type)
    }

    func get<T: Decodable>(at path: PathComponent..., query: [String : String] = [:], expiry: Expiry = .minutes(30), type: T.Type = T.self) -> EventLoopFuture<T> {
        return get(at: path, query: query, expiry: expiry, type: type)
    }

    func get<T: Decodable>(at path: PathComponent..., query: [String : String] = [:], expiry: Expiry = .minutes(30)) -> EventLoopFuture<Paging<T>> {
        return get(at: path, query: query, expiry: expiry, type: Page<T>.self).map { page in
            return Paging(client: self, first: page, path: path, query: query)
        }
    }

    func post<T: Decodable>(at path: [PathComponent], query: [String : String] = [:], body: JSON?, expiry: Expiry = .minutes(30), type: T.Type = T.self) -> EventLoopFuture<T> {
        return request(.POST, at: path, query: query, body: body, expiry: expiry, type: type)
    }

    func post<T: Decodable>(at path: PathComponent..., query: [String : String] = [:], body: JSON?, expiry: Expiry = .minutes(30), type: T.Type = T.self) -> EventLoopFuture<T> {
        return post(at: path, query: query, body: body, expiry: expiry, type: type)
    }
}

extension EventLoopFuture where Value == HTTPClient.Response {

    fileprivate func decode<T: Decodable>(type: T.Type = T.self) -> EventLoopFuture<T> {
        return flatMapThrowing { try $0.decode(type: type) }
    }

}

extension HTTPClient.Response {

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
        return decoder
    }()

    fileprivate func decode<T: Decodable>(type: T.Type = T.self) throws -> T {
        guard let buffer = body else {
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

extension HTTPMethod: Hashable { }

extension StorageAware {

    func nonExpiredObject(_ key: Key) -> Value? {
        guard let entry = try? self.entry(forKey: key), !entry.expiry.isExpired else {
            return nil
        }
        return entry.object
    }

}
