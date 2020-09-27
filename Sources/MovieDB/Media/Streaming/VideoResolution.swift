
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
        if let specialCase = VideoResolution.specialCases[rawValue] {
            self = specialCase
            return
        }

        guard let resolution = VideoResolution(rawValue: rawValue) else {
            throw DecodingError.typeMismatch(VideoResolution.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Value \(rawValue) is not supported by VideoResolution"))
        }

        self = resolution
    }
}

extension VideoResolution {

    private static let specialCases: [String : VideoResolution] = [
        "canvas" : .theatre,
        "4k" : .ultraHD,
    ]

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
