
import Foundation
import GraphZahl

class Price: GraphQLObject {
    let amount: Double
    let currency: String

    init(amount: Double, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}
