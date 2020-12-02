
import Foundation

class DetailedPerson: Person {
    let birthday: Date?
    let knownForDepartment: String
    let deathday: Date?
    let alsoKnownAs: [String]
    let gender: Gender
    let biography: String
    let placeOfBirth: String?
    let imdbID: String?
    let homepage: URL?

    private enum CodingKeys: String, CodingKey {
        case birthday
        case knownForDepartment = "known_for_department"
        case deathday, id, name
        case alsoKnownAs = "also_known_as"
        case gender, biography, popularity
        case placeOfBirth = "place_of_birth"
        case profilePicture = "profile_path"
        case isAdult = "adult"
        case imdbID = "imdb_id"
        case homepage
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        birthday = try container.decodeIfPresent(Date.self, forKey: .birthday)
        knownForDepartment = try container.decode(String.self, forKey: .knownForDepartment)
        deathday = try container.decodeIfPresent(Date.self, forKey: .deathday)
        alsoKnownAs = try container.decode([String].self, forKey: .alsoKnownAs)
        gender = try container.decode(Gender.self, forKey: .gender)
        biography = try container.decode(String.self, forKey: .biography)
        placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth)
        imdbID = try container.decodeIfPresent(String.self, forKey: .imdbID)
        homepage = try container.decodeIfPresent(URL.self, forKey: .homepage)
        try super.init(from: decoder)
    }
}
