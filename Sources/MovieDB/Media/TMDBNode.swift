
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

    var graphqlID: ID {
        return ID(namespace: Self.namespace, ids: [String(self.id)])
    }

    func id(context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        return eventLoop.future(graphqlID.string())
    }

    static func find(id: String, context: MutableContext, eventLoop: EventLoopGroup) -> EventLoopFuture<GraphZahl.Node?> {
        guard let wrapped = ID(id), wrapped.namespace == Self.namespace, wrapped.ids.count == 1 else { return eventLoop.future(nil) }
        let ids = wrapped.intIds()
        return find(id: ids[0], viewerContext: context.anyViewerContext as! MovieDB.ViewerContext).map { $0 }
    }

}

struct ID: Hashable {
    enum Namespace: Int, Hashable {
        case movie
        case person
        case show
        case season
        case episode

        case genre
        case keyword
        case productionCompany
        case network

        case stremingProvider
        case streamingCountry
    }

    let namespace: Namespace
    let ids: [String]

    func string() -> String {
        let ids = self.ids.joined(separator: ":")
        return "\(namespace.rawValue):\(ids)".data(using: .ascii)!.base64EncodedString()
    }

    func intIds() -> [Int] {
        return ids.compactMap(Int.init)
    }
}

extension ID {
    init(_ ids: Int..., for namespace: Namespace) {
        self.init(namespace: namespace, ids: ids.map(String.init))
    }
}

extension ID {
    init?(_ stringRepresentation: String) {
        guard let data = Data(base64Encoded: stringRepresentation),
              let decoded = String(data: data, encoding: .ascii) else { return nil }

        let parts = decoded.components(separatedBy: ":").filter { !$0.isEmpty }

        guard parts.count > 1,
              let namespaceValue = Int(parts[0]),
              let namespace = Namespace(rawValue: namespaceValue) else { return nil }

        self.init(namespace: namespace, ids: Array(parts.dropFirst()))
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
        case invalidNumberOfComponents(expected: Int, actual: Int)
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<[Int]> {
        guard self.namespace == namespace else {
            return eventLoop.future(error: Error.invalidId(desiredNamespace: namespace))
        }

        let ids = intIds()

        return eventLoop.future(ids)
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<Int> {
        return eventLoop.tryFuture {
            guard self.namespace == namespace else {
                throw Error.invalidId(desiredNamespace: namespace)
            }
            let ids = intIds()

            guard ids.count == 1 else {
                throw Error.invalidNumberOfComponents(expected: 1, actual: ids.count)
            }

            return ids[0]
        }
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<String> {
        return eventLoop.tryFuture {
            guard self.namespace == namespace else {
                throw Error.invalidId(desiredNamespace: namespace)
            }

            guard ids.count == 1 else {
                throw Error.invalidNumberOfComponents(expected: 1, actual: ids.count)
            }

            return ids[0]
        }
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<(Int, Int)> {
        return eventLoop.tryFuture {
            guard self.namespace == namespace else {
                throw Error.invalidId(desiredNamespace: namespace)
            }
            let ids = intIds()

            guard ids.count == 2 else {
                throw Error.invalidNumberOfComponents(expected: 2, actual: ids.count)
            }

            return (ids[0], ids[1])
        }
    }

    func idValue(for namespace: Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<(Int, Int, Int)> {
        return eventLoop.tryFuture {
            guard self.namespace == namespace else {
                throw Error.invalidId(desiredNamespace: namespace)
            }
            let ids = intIds()

            guard ids.count == 3 else {
                throw Error.invalidNumberOfComponents(expected: 3, actual: ids.count)
            }

            return (ids[0], ids[1], ids[2])
        }
    }
}

extension Sequence where Element == ID {

    func idValues(for namespace: ID.Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<[Int]> {
        return eventLoop.tryFuture {
            var values = [Int]()
            for id in self {
                guard id.namespace == namespace else {
                    throw ID.Error.invalidId(desiredNamespace: namespace)
                }
                let ids = id.intIds()

                guard ids.count == 1 else {
                    throw ID.Error.invalidNumberOfComponents(expected: 1, actual: ids.count)
                }

                values.append(ids[0])
            }
            return values
        }
    }

    func idStringValues(for namespace: ID.Namespace, eventLoop: EventLoopGroup) -> EventLoopFuture<[String]> {
        return eventLoop.tryFuture {
            var values = [String]()
            for id in self {
                guard id.namespace == namespace else {
                    throw ID.Error.invalidId(desiredNamespace: namespace)
                }

                guard id.ids.count == 1 else {
                    throw ID.Error.invalidNumberOfComponents(expected: 1, actual: id.ids.count)
                }

                values.append(id.ids[0])
            }
            return values
        }
    }
}
