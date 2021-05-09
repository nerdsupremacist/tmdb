
import Foundation
import GraphZahl
import NIO
import ContextKit
import GraphQL

protocol TMDBNode: GraphZahl.Node {
    static var namespace: ID.Namespace { get }

    var id: Int { get }
    static func find(id: Int, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TMDBNode>
}

extension TMDBNode {

    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        let id = ID(namespace: Self.namespace, id: id)
        return eventLoop.future(id.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<GraphZahl.Node?> {
        guard let wrapped = ID(id), wrapped.namespace == Self.namespace else { return eventLoop.future(nil) }
        return find(id: wrapped.id, viewerContext: context.anyViewerContext as! MovieDB.ViewerContext).map { $0 }
    }

}

struct ID {
    enum Namespace: Int {
        case movie
        case person
        case show
    }

    fileprivate let namespace: Namespace
    fileprivate let id: Int

    func string() -> String {
        return "\(namespace.rawValue):\(id)".data(using: .ascii)!.base64EncodedString()
    }
}

extension ID {
    init?(_ stringRepresentation: String) {
        guard let data = Data(base64Encoded: stringRepresentation),
              let decoded = String(data: data, encoding: .ascii) else { return nil }

        let parts = decoded.components(separatedBy: ":").filter { !$0.isEmpty }

        guard parts.count == 2,
              let namespaceValue = Int(parts[0]),
              let namespace = Namespace(rawValue: namespaceValue),
              let id = Int(parts[1]) else { return nil }

        self.init(namespace: namespace, id: id)
    }
}

extension ID: GraphQLScalar {

    static var concreteTypeName: String {
        return "ID"
    }

    init(scalar: ScalarValue) throws {
        guard let id = ID(try scalar.string()) else {
            throw ScalarTypeError.valueFailedInnerTypeConstraints(scalar, forType: Self.self)
        }
        self = id
    }

    func encodeScalar() throws -> ScalarValue {
        return try string().encodeScalar()
    }

    static func resolve() throws -> GraphQLScalarType {
        return GraphQLID
    }

}

extension ID {

    enum Error: Swift.Error {
        case invalidId(desiredNamespace: Namespace)
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        guard self.namespace == namespace else {
            return eventLoop.future(error: Error.invalidId(desiredNamespace: namespace))
        }

        return eventLoop.future(id)
    }

}
