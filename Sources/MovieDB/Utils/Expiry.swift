
import Foundation
import Cache

extension Expiry {
    // Since a day is technically not a measure of time but a measure of the calendar
    static func pseudoDays(_ days: TimeInterval) -> Expiry {
        return .hours(days * 24)
    }

    static func hours(_ hr: TimeInterval) -> Expiry {
        return .minutes(hr * 60)
    }

    static func minutes(_ min: TimeInterval) -> Expiry {
        return .seconds(min * 60)
    }
}

