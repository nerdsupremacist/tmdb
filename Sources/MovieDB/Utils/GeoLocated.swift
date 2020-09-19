
import Foundation

struct GeoLocated: Decodable {
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code2"
        case languages
    }

    let countryCode: String
    let languages: String
}

extension GeoLocated {

    var locale: String {
        let initialLanguage = languages.split(separator: ",")[0].split(separator: "-")[0]
        return "\(initialLanguage.lowercased())_\(countryCode.uppercased())"
    }

}
