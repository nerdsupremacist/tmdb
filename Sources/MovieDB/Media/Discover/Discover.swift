
import Foundation
import GraphZahl
import NIO
import GraphQL
import ContextKit

protocol InputMergable {
    func merge(with other: Self) -> Self
}

extension Optional: InputMergable where Wrapped: InputMergable {

    func merge(with other: Optional<Wrapped>) -> Optional<Wrapped> {
        switch (self, other) {
        case (.some(let lhs), .some(let rhs)):
            return lhs.merge(with: rhs)
        case (_, .some):
            return other
        case (_, .none):
            return self
        }
    }

}

extension Bool: InputMergable {
    func merge(with other: Bool) -> Bool {
        return self && other
    }
}

extension Array: InputMergable where Element: Hashable {

    func merge(with other: Array<Element>) -> Array<Element> {
        return Array(Set(self + other))
    }

}

struct DiscoverInput: GraphQLInputObject {
    var people: DiscoverIncludeFilter? = nil
    var cast: DiscoverIncludeFilter? = nil
    var crew: DiscoverIncludeFilter? = nil
    var genres: DiscoverIncludeExcludeFilter? = nil
    var keywords: DiscoverIncludeExcludeFilter? = nil
    var companies: DiscoverIncludeExcludeFilter? = nil
    var voteCount: DiscoverIntFilter? = nil
    var rating: DiscoverFloatFilter? = nil
    var runtime: DiscoverIntFilter? = nil

    var streamingOptions: StreamingOptions? = nil

    func parameters(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        let futures = [
            people?.parameters(for: "people", in: .person, viewerContext: viewerContext),
            cast?.parameters(for: "people", in: .person, viewerContext: viewerContext),
            crew?.parameters(for: "people", in: .person, viewerContext: viewerContext),
            genres?.parameters(for: "genres", in: .genre, viewerContext: viewerContext),
            keywords?.parameters(for: "keywords", in: .keyword, viewerContext: viewerContext),
            companies?.parameters(for: "companies", in: .productionCompany, viewerContext: viewerContext),
            voteCount?.parameters(for: "vote_count", viewerContext: viewerContext),
            rating?.parameters(for: "vote_average", viewerContext: viewerContext),
            runtime?.parameters(for: "with_runtime", viewerContext: viewerContext),
            streamingOptions?.parameters(viewerContext: viewerContext),
        ].compactMap { $0 }

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce([:]) { $0.merging($1) { $1 } } }
    }

    func merge(with other: DiscoverInput) -> DiscoverInput {
        return DiscoverInput(people: people.merge(with: other.people),
                             cast: cast.merge(with: other.cast),
                             crew: crew.merge(with: other.crew),
                             genres: genres.merge(with: other.genres),
                             keywords: keywords.merge(with: other.keywords),
                             voteCount: voteCount.merge(with: other.voteCount),
                             rating: rating.merge(with: other.rating),
                             runtime: runtime.merge(with: other.runtime),
                             streamingOptions: streamingOptions.merge(with: other.streamingOptions))
    }

}

struct MovieDiscoverInput: GraphQLInputObject, InputMergable {
    var releaseDate: DiscoverDateFilter? = nil
    var includeAdult: Bool? = nil
    var includeVideo: Bool? = nil

    func parameters(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        let futures = [
            releaseDate?.parameters(for: "release_date", viewerContext: viewerContext),
        ].compactMap { $0 }

        let initial = [
            "include_adult" : String(includeAdult ?? false),
            "include_video" : String(includeVideo ?? false),
        ]

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce(initial) { $0.merging($1) { $1 } } }
    }

    func merge(with other: MovieDiscoverInput) -> MovieDiscoverInput {
        return MovieDiscoverInput(releaseDate: releaseDate.merge(with: other.releaseDate),
                                  includeAdult: includeAdult.merge(with: other.includeAdult),
                                  includeVideo: includeVideo.merge(with: other.includeVideo))
    }
}

struct TVDiscoverInput: GraphQLInputObject, InputMergable {
    var airDate: DiscoverDateFilter? = nil
    var firstAirDate: DiscoverDateFilter? = nil
    var networks: DiscoverIncludeFilter? = nil

    func parameters(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        let futures = [
            networks?.parameters(for: "with_networks", in: .network, viewerContext: viewerContext),
            airDate?.parameters(for: "air_date", viewerContext: viewerContext),
            firstAirDate?.parameters(for: "first_air_date", viewerContext: viewerContext),
        ].compactMap { $0 }

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce([:]) { $0.merging($1) { $1 } } }
    }

    func merge(with other: TVDiscoverInput) -> TVDiscoverInput {
        return TVDiscoverInput(airDate: airDate.merge(with: other.airDate),
                               firstAirDate: firstAirDate.merge(with: other.firstAirDate),
                               networks: networks.merge(with: other.networks))
    }
}

struct StreamingOptions: GraphQLInputObject, InputMergable {
    var country: ID? = nil
    var streamingProviders: [ID] = []
    var monetizationTypes: [StreamingMonetizationType]? = nil

    func parameters(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        let providers = streamingProviders.idValues(for: .stremingProvider, eventLoop: viewerContext.request.eventLoop)
        let selectedCountry = country?.idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop).map(Optional.some)
            ?? viewerContext.locale(locale: nil)

        let allCountries = viewerContext.countries()

        return providers.and(selectedCountry).and(allCountries).map { (selected, allCountries) in
            let (providers, selectedCountry) = selected
            var parameters: [String : String] = [:]
            let monetization = monetizationTypes ?? [.flatrate, .free, .ads]
            parameters["with_watch_monetization_types"] = monetization.map(\.rawValue).joined(separator: "|")

            if !providers.isEmpty {
                parameters["with_watch_providers"] = providers.map(String.init).joined(separator: "|")
                if let selectedCountry = selectedCountry?.lowercased(),
                    let country = allCountries.first(where: { $0.locale.lowercased() == selectedCountry }) {

                    parameters["watch_region"] = country.iso3166_2.uppercased()
                }
            }
            return parameters
        }
    }

    func merge(with other: StreamingOptions) -> StreamingOptions {
        return StreamingOptions(country: other.country ?? country,
                                streamingProviders: streamingProviders.merge(with: other.streamingProviders),
                                monetizationTypes: monetizationTypes.merge(with: other.monetizationTypes))
    }
}

struct DiscoverIncludeFilter: GraphQLInputObject, InputMergable {
    let include: [ID]

    func parameters(for name: String, in namespace: ID.Namespace, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        guard !include.isEmpty else { return viewerContext.request.eventLoop.future([:]) }
        return include.idValues(for: namespace, eventLoop: viewerContext.request.eventLoop).map { ids in
            return ["with_\(name)" : ids.map(String.init).joined(separator: ",")]
        }
    }

    func merge(with other: DiscoverIncludeFilter) -> DiscoverIncludeFilter {
        return DiscoverIncludeFilter(include: include.merge(with: other.include))
    }
}

struct DiscoverIncludeExcludeFilter: GraphQLInputObject, InputMergable {
    var include: [ID]? = nil
    var exclude: [ID]? = nil

    func parameters(for name: String, in namespace: ID.Namespace, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        let futures: [EventLoopFuture<[String : String]>] = [
            include?.idValues(for: namespace, eventLoop: viewerContext.request.eventLoop).map { ids in
                guard !ids.isEmpty else { return [:] }
                return ["with_\(name)" : ids.map(String.init).joined(separator: ",")]
            },
            exclude?.idValues(for: namespace, eventLoop: viewerContext.request.eventLoop).map { ids in
                guard !ids.isEmpty else { return [:] }
                return ["without_\(name)" : ids.map(String.init).joined(separator: ",")]
            }
        ].compactMap { $0 }

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce([:]) { $0.merging($1) { $1 } } }
    }

    func merge(with other: DiscoverIncludeExcludeFilter) -> DiscoverIncludeExcludeFilter {
        return DiscoverIncludeExcludeFilter(include: include.merge(with: other.include), exclude: exclude.merge(with: exclude))
    }
}

private func mergeMax<C : Comparable>(_ lhs: C?, _ rhs: C?) -> C? {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return min(lhs, rhs)
    case (_, .some):
        return rhs
    case (_, .none):
        return lhs
    }
}

private func mergeMin<C : Comparable>(_ lhs: C?, _ rhs: C?) -> C? {
    switch (lhs, rhs) {
    case (.some(let lhs), .some(let rhs)):
        return max(lhs, rhs)
    case (_, .some):
        return rhs
    case (_, .none):
        return lhs
    }
}

struct DiscoverFloatFilter: GraphQLInputObject, InputMergable {
    let min: Double?
    let max: Double?

    func parameters(for name: String, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        var parameters: [String : String] = [:]
        if let min = min {
            parameters["\(name).gte"] = String(min)
        }
        if let max = max {
            parameters["\(name).lte"] = String(max)
        }
        return viewerContext.request.eventLoop.future(parameters)
    }

    func merge(with other: DiscoverFloatFilter) -> DiscoverFloatFilter {
        return DiscoverFloatFilter(min: mergeMin(min, other.min), max: mergeMax(max, other.max))
    }
}

struct DiscoverIntFilter: GraphQLInputObject, InputMergable {
    let min: Int?
    let max: Int?

    func parameters(for name: String, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {
        var parameters: [String : String] = [:]
        if let min = min {
            parameters["\(name).gte"] = String(min)
        }
        if let max = max {
            parameters["\(name).lte"] = String(max)
        }
        return viewerContext.request.eventLoop.future(parameters)
    }

    func merge(with other: DiscoverIntFilter) -> DiscoverIntFilter {
        return DiscoverIntFilter(min: mergeMin(min, other.min), max: mergeMax(max, other.max))
    }
}

struct DiscoverDateFilter: GraphQLInputObject, InputMergable {
    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    let min: Date?
    let max: Date?

    func parameters(for name: String, viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<[String : String]> {

            var parameters: [String : String] = [:]
            if let min = min {
                parameters["\(name).gte"] = Self.formatter.string(from: min)
            }
            if let max = max {
                parameters["\(name).lte"] = Self.formatter.string(from: max)
            }
            return viewerContext.request.eventLoop.future(parameters)
    }

    func merge(with other: DiscoverDateFilter) -> DiscoverDateFilter {
        return DiscoverDateFilter(min: mergeMin(min, other.min), max: mergeMax(max, other.max))
    }
}

class Discover: GraphQLObject {
    static var additionalArguments: [String : InputResolvable.Type] {
        return [
            "input" : (DiscoverInput?).self,
        ]
    }

    private let viewerContext: MovieDB.ViewerContext
    private var input: DiscoverInput

    init(viewerContext: MovieDB.ViewerContext, initialInput: DiscoverInput = DiscoverInput()) {
        self.viewerContext = viewerContext
        self.input = initialInput
    }

    var movies: DiscoverMovies {
        return DiscoverMovies(input: input, movieInitialInput: MovieDiscoverInput(), viewerContext: viewerContext)
    }

    var tv: DiscoverTV {
        return DiscoverTV(input: input, initialTVInput: TVDiscoverInput(), viewerContext: viewerContext)
    }

    final func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> Output {
        self.input = try arguments["input"].flatMap { self.input.merge(with: try DiscoverInput.create(from: $0)) } ?? self.input
        return .object(self)
    }
}

class DiscoverMovies: GraphQLObject {
    static var additionalArguments: [String : InputResolvable.Type] {
        return [
            "input" : (MovieDiscoverInput?).self,
        ]
    }

    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    private let viewerContext: MovieDB.ViewerContext
    private let input: DiscoverInput
    private var movieInput: MovieDiscoverInput

    init(input: DiscoverInput, movieInitialInput: MovieDiscoverInput, viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
        self.input = input
        self.movieInput = movieInitialInput
    }

    func topRated() -> EventLoopFuture<Movie.Connection> {
        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "vote_average.desc"
            return self.viewerContext.movies(at: "discover", "movie", query: parameters)
        }
    }

    func popular() -> EventLoopFuture<Movie.Connection> {
        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "popularity.desc"
            return self.viewerContext.movies(at: "discover", "movie", query: parameters)
        }
    }

    func latest() -> EventLoopFuture<Movie.Connection> {
        let today = Self.formatter.string(from: Date())
        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "release_date.desc"
            if parameters["first_air_date.lte"] == nil {
                parameters["release_date.lte"] = today
            }
            return self.viewerContext.movies(at: "discover", "movie", query: parameters)
        }
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> Output {
        self.movieInput = try arguments["input"].flatMap { self.movieInput.merge(with: try MovieDiscoverInput.create(from: $0)) } ?? self.movieInput
        return .object(self)
    }

    private func parameters() -> EventLoopFuture<[String : String]> {
        let futures = [
            input.parameters(viewerContext: viewerContext),
            movieInput.parameters(viewerContext: viewerContext),
        ]

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce([:]) { $0.merging($1) { $1 } } }
    }
}

class DiscoverTV: GraphQLObject {
    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    static var additionalArguments: [String : InputResolvable.Type] {
        return [
            "input" : (TVDiscoverInput?).self,
        ]
    }

    private let viewerContext: MovieDB.ViewerContext
    private let input: DiscoverInput
    private var tvInput: TVDiscoverInput

    init(input: DiscoverInput, initialTVInput: TVDiscoverInput, viewerContext: MovieDB.ViewerContext) {
        self.viewerContext = viewerContext
        self.input = input
        self.tvInput = initialTVInput
    }

    func topRated() -> EventLoopFuture<TVShow.Connection> {
        return input.parameters(viewerContext: viewerContext).flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "vote_average.desc"
            if parameters["vote_count.gte"] == nil {
                parameters["vote_count.gte"] = "100"
            }
            return self.viewerContext.shows(at: "discover", "movie", query: parameters)
        }
    }

    func popular() -> EventLoopFuture<TVShow.Connection> {
        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "popularity.desc"
            return self.viewerContext.shows(at: "discover", "movie", query: parameters)
        }
    }

    func latest() -> EventLoopFuture<TVShow.Connection> {
        let today = Self.formatter.string(from: Date())
        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "first_air_date.desc"
            if parameters["first_air_date.lte"] == nil {
                parameters["first_air_date.lte"] = today
            }
            return self.viewerContext.shows(at: "discover", "movie", query: parameters)
        }
    }

    func onTheAir() -> EventLoopFuture<TVShow.Connection> {
        let today = Self.formatter.string(from: Date())
        let calendar = Calendar.current
        let nextWeek = calendar
            .date(byAdding: DateComponents(day: 7), to: Date())
            .map(Self.formatter.string(from:)) ?? today

        return parameters().flatMap { parameters in
            var parameters = parameters
            parameters["sort_by"] = "release_date.desc"
            if parameters["air_date.gte"] == nil && parameters["air_date.lte"] == nil {
                parameters["air_date.gte"] = today
                parameters["air_date.lte"] = nextWeek
            }
            return self.viewerContext.shows(at: "discover", "tv", query: parameters)
        }
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> Output {
        self.tvInput = try arguments["input"].flatMap { self.tvInput.merge(with: try TVDiscoverInput.create(from: $0)) } ?? self.tvInput
        return .object(self)
    }

    private func parameters() -> EventLoopFuture<[String : String]> {
        let futures = [
            input.parameters(viewerContext: viewerContext),
            tvInput.parameters(viewerContext: viewerContext),
        ]

        return viewerContext.request.eventLoop.flatten(futures).map { $0.reduce([:]) { $0.merging($1) { $1 } } }
    }
}

class FullDiscoverTV: DelegatedOutputResolvable {
    static var additionalArguments: [String : InputResolvable.Type] {
        return [
            "input" : (TVDiscoverInput?).self,
            "otherFilters" : (DiscoverInput?).self,
        ]
    }

    private let viewerContext: MovieDB.ViewerContext
    private let initialInput: DiscoverInput
    private var initialTVInput: TVDiscoverInput


    init(viewerContext: MovieDB.ViewerContext, initialInput: DiscoverInput, initialTVInput: TVDiscoverInput) {
        self.viewerContext = viewerContext
        self.initialInput = initialInput
        self.initialTVInput = initialTVInput
    }

    func resolve(source: Any, arguments: [String : Map], context: MutableContext, eventLoop: EventLoopGroup) throws -> some OutputResolvable {
        let input = try arguments["input"].flatMap { try TVDiscoverInput?.create(from: $0) } ?? TVDiscoverInput()
        let otherFilters = try arguments["otherFilters"].flatMap { try DiscoverInput?.create(from: $0) } ?? DiscoverInput()
        return DiscoverTV(input: initialInput.merge(with: otherFilters), initialTVInput: initialTVInput.merge(with: input), viewerContext: viewerContext)
    }
}
