
import Foundation
import GraphZahl
import NIO

class StreamingResultForProvideer: GraphQLObject {
    @Ignore
    var providerID: Int

    let bestOption: StreamingCountryOption
    let options: [StreamingCountryOption]

    init(providerID: Int, options: [StreamingCountryOption]) {
        self.providerID = providerID
        self.bestOption = options.min { $0.option.bestOffering.isBetterThan(other: $1.option.bestOffering) }!
        self.options = options
    }

    func provider(viewerContext: MovieDB.ViewerContext, country: ID?) -> EventLoopFuture<StreamingProvider?> {
        let locale: EventLoopFuture<String?> = country?
            .idValue(for: .streamingCountry, eventLoop: viewerContext.request.eventLoop)
            .map(Optional.some) ?? viewerContext.request.eventLoop.future(nil)

        return locale.flatMap { locale in
            return viewerContext.streamingProviders(locale: locale).map { $0?.first(where: { $0.id == self.providerID }) }
        }
    }
}

class StreamingCountryOption: GraphQLObject {
    @Ignore
    var locale: String

    let option: StreamingOption

    init(locale: String, option: StreamingOption) {
        self.locale = locale
        self.option = option
    }

    func country(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<StreamingCountry> {
        let locale = self.locale.lowercased()
        return viewerContext.countries().map { $0.first { $0.locale.lowercased() == locale }! }
    }
}

extension StreamingCountry {
    enum Error: Swift.Error {
        case countryNotFound(locale: String)
    }
}

extension MovieDB.ViewerContext {

    private struct SearchResultsForLocale {
        let locale: String
        let options: [StreamingOption]
    }

    func searchStreamingOptions(providers: [ID],
                                countries: [ID]?,
                                search: @escaping (String) -> EventLoopFuture<[StreamingOption]?>) -> EventLoopFuture<[StreamingResultForProvideer]> {

        guard !providers.isEmpty else { return request.eventLoop.future([]) }
        return locales(ids: countries).flatMap { locales in
            return self.searchStreamingOptions(providers: providers, locales: locales, search: search)
        }
    }

    private func searchStreamingOptions(providers: [ID],
                                        locales: [String],
                                        search: @escaping (String) -> EventLoopFuture<[StreamingOption]?>) -> EventLoopFuture<[StreamingResultForProvideer]> {

        let searches = locales.map { locale in
            return search(locale)
                .flatMapError { _ in self.request.eventLoop.future(nil) }
                .map { SearchResultsForLocale(locale: locale, options: $0 ?? []) }
        }
        let flattened = request.eventLoop.flatten(searches)
        let providerIds = providerIds(ids: providers)
        return providerIds.and(flattened).map { providerIds, results in
            let providerIds = Set(providerIds)
            var byProviderId: [Int : [StreamingCountryOption]] = [:]
            for result in results {
                for option in result.options where providerIds.contains(option.providerID) {
                    byProviderId[option.providerID, default: []].append(StreamingCountryOption(locale: result.locale, option: option))
                }
            }

            return byProviderId
                .map { StreamingResultForProvideer(providerID: $0.key, options: $0.value) }
                .sorted { $0.bestOption.option.bestOffering.isBetterThan(other: $1.bestOption.option.bestOffering) }
        }
    }

    private func providerIds(ids: [ID]) -> EventLoopFuture<[Int]> {
        return request.eventLoop.tryFuture {
            var newIds: [Int] = []
            for id in ids {
                guard id.namespace == .stremingProvider else { throw ID.Error.invalidId(desiredNamespace: .streamingCountry) }
                let intIds = id.intIds()
                guard intIds.count == 1 else { throw ID.Error.invalidNumberOfComponents(expected: 1, actual: intIds.count) }
                newIds.append(intIds[0])
            }
            return newIds
        }
    }

    private func locales(ids: [ID]?) -> EventLoopFuture<[String]> {
        guard let ids = ids else { return countries().map { $0.map(\.locale) } }
        return request.eventLoop.tryFuture {
            var locales: [String] = []
            for id in ids {
                guard id.namespace == .streamingCountry else { throw ID.Error.invalidId(desiredNamespace: .streamingCountry) }
                guard id.ids.count == 1 else { throw ID.Error.invalidNumberOfComponents(expected: 1, actual: id.ids.count) }
                locales.append(id.ids[0])
            }
            return locales
        }
    }

}
