
import Foundation
import NIO
import Vapor

extension MovieDB.ViewerContext {

    func locale() -> EventLoopFuture<String?> {
        if let ipAddress = request.headers.forwarded.first?.for ?? request.remoteAddress?.ipAddress, ipAddress != "127.0.0.1", ipAddress != "172.17.0.1" {
            return geoLocation.get(at: "ipgeo", query: ["ip" : ipAddress], expiry: .pseudoDays(14))
                .map { (located: GeoLocated) in
                    return located.locale
                }
                .flatMapError { _ in self.request.eventLoop.future(nil) }
        }

        // For debugging purposes return USA when running in localhost
        if request.application.environment == .development {
            return request.eventLoop.future("de_DE")
        }

        if let acceptedLocale = request.headers[.acceptLanguage].first {
            let locale = Locale(identifier: acceptedLocale)
            if let languageCode = locale.languageCode, let regionCode = locale.regionCode {
                return request.eventLoop.future("\(languageCode)_\(regionCode)")
            }
        }

        return request.eventLoop.future(nil)
    }

}
