
import Foundation
import GraphZahl

class Translation<Info: Decodable & OutputResolvable & ConcreteResolvable>: Decodable, GraphQLObject {
    static var concreteTypeName: String {
        return "TranslationWith\(Info.concreteTypeName)"
    }

    let iso3166_1, iso639_1: String
    let localizedLanguage, language: String?
    let info: Info

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case iso639_1 = "iso_639_1"
        case localizedLanguage = "name"
        case language = "english_name"
        case info = "data"
    }
}

class TranslatedMovieInfo: Decodable, GraphQLObject {
    let title, overview: String
}

class TranslatedPersonInfo: Decodable, GraphQLObject {
    let biography: String
}

class Translations<Info: Decodable & OutputResolvable & ConcreteResolvable>: Decodable {
    let translations: [Translation<Info>]
}
