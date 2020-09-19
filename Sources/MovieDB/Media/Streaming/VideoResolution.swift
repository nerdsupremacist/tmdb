
import Foundation
import GraphZahl

enum VideoResolution: String, Decodable, CaseIterable, GraphQLEnum {
    case theatre
    case dvd
    case bluray
    case sd
    case hd
    case ultraHD

    init(from decoder: Decoder) throws {
        let rawValue = try String(from: decoder)
        switch rawValue {
        case "canvas":
            self = .theatre
        case "4k":
            self = .ultraHD
            return
        default:
            break
        }

        guard let resolution = VideoResolution(rawValue: rawValue) else {
            throw DecodingError.typeMismatch(VideoResolution.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Value \(rawValue) is not supported by VideoResolution"))
        }

        self = resolution
    }
}

extension VideoResolution {

    var ranking: Int {
        switch self {
        case .ultraHD:
            return 0
        case .hd:
            return 1
        case .sd:
            return 2
        case .bluray:
            return 3
        case .dvd:
            return 4
        case .theatre:
            return 5
        }
    }

}
