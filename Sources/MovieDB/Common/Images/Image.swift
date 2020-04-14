
import Foundation
import GraphQL
import GraphZahl
import ContextKit
import NIO

enum BackdropSize: String, CaseIterable, GraphQLEnum {
    case w300, w780, w1280, original
}

enum PosterSize: String, CaseIterable, GraphQLEnum {
    case w92, w154, w185, w342, w500, w780, original
}

enum ProfileSize: String, CaseIterable, GraphQLEnum {
    case w45, w185, h632, original
}

enum StillSize: String, CaseIterable, GraphQLEnum {
    case w92, w185, w300, original
}

enum LogoSize: String, CaseIterable, GraphQLEnum {
    case w45, w92, w154, w185, w300, w500, original
}

class Image<Size : RawRepresentable>: Decodable where Size.RawValue == String {
    private let path: String

    required init(from decoder: Decoder) throws {
        path = try String(from: decoder)
    }

    func url(size: Size, client: Client) -> URL {
        return client.imagesBase.appendingPathComponent(size.rawValue).appendingPathComponent(path)
    }
}

extension Image: Resolvable where Size: Resolvable { }

extension Image: OutputResolvable where Size: InputResolvable & ConcreteResolvable {

    static var additionalArguments: [String : InputResolvable.Type] {
        return [
            "size" : Size.self
        ]
    }

    static func reference(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.reference(for: URL.self)
    }

    static func resolve(using context: inout Resolution.Context) throws -> GraphQLOutputType {
        return try context.resolve(type: URL.self)
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> EventLoopFuture<Any?> {
        let url = self.url(size: try Size.create(from: arguments["size"]!), client: context.anyViewerContext as! Client)
        return url.resolve(source: source, arguments: arguments, context: context, eventLoop: eventLoop)
    }
}
