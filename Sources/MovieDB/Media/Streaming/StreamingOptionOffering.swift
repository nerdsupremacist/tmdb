
import Foundation
import GraphZahl

class StreamingOptionOffering: GraphQLObject {
    let price: Price?
    let type: StreamingMonetizationType
    let resolution: VideoResolution
    let links: StreamingLinks

    init(decoded: DecodedStreamingOption) {
        self.price = decoded.retailPrice.flatMap { amount in decoded.currency.map { currency in Price(amount: amount, currency: currency) } }
        self.type = decoded.type
        self.resolution = decoded.resolution
        self.links = decoded.links
    }
}

extension StreamingOptionOffering {
    func isBetterThan(other: StreamingOptionOffering) -> Bool {
        if type.ranking < other.type.ranking {
            return true
        }

        if type.ranking > other.type.ranking {
            return false
        }

        if resolution.ranking < other.resolution.ranking {
            return true
        }

        if resolution.ranking > other.resolution.ranking {
            return false
        }

        switch (price, other.price) {
        case (.none, .none):
            return false
        case (.some(let lhs), .some(let rhs)):
            if lhs.currency == rhs.currency {
                return lhs.amount < rhs.amount
            }
            return false
        case (.none, _):
            return true
        case (_, .none):
            return false
        }
    }
}
