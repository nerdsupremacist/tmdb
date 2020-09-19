
import Foundation
import GraphZahl

enum StreamingMonetizationType: String, Decodable, CaseIterable, GraphQLEnum {
    case ads = "ads"
    case buy = "buy"
    case cinema = "cinema"
    case flatrate = "flatrate"
    case free = "free"
    case rent = "rent"
}

extension StreamingMonetizationType {

    var ranking: Int {
        switch self {
        case .free:
            return 0
        case .flatrate:
            return 1
        case .ads:
            return 2
        case .rent:
            return 3
        case .cinema:
            return 4
        case .buy:
            return 5
        }
    }

}
