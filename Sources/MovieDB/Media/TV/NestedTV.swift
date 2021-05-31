
import Foundation
import GraphZahl
import NIO

class NestedTV: GraphQLObject {
    private static let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    @Ignore
    var filter: String

    @Ignore
    var id: Int

    private init(filter: String, id: Int) {
        self.filter = filter
        self.id = id
    }

    func onTheAir(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        let today = NestedTV.formatter.string(from: Date())
        let calendar = Calendar.current
        let nextWeek = calendar
            .date(byAdding: DateComponents(day: 7), to: Date())
            .map(NestedTV.formatter.string(from:)) ?? today

        return viewerContext.shows(at: "discover", "tv",
                                   query: [
                                    filter : String(id),
                                    "sort_by" : "popularity.desc",
                                    "air_date.gte" : today,
                                    "air_date.lte" : nextWeek,
                                   ])

    }

    func latest(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        let today = NestedTV.formatter.string(from: Date())
        return viewerContext.shows(at: "discover", "tv",
                                   query: [
                                    filter : String(id),
                                    "sort_by" : "first_air_date.desc",
                                    "first_air_date.lte" : today,
                                   ])
    }

    func popular(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "discover", "tv",
                                   query: [
                                    filter : String(id),
                                    "sort_by" : "popularity.desc",
                                   ])
    }

    func topRated(viewerContext: MovieDB.ViewerContext) -> EventLoopFuture<TVShow.Connection> {
        return viewerContext.shows(at: "discover", "tv",
                                   query: [
                                    filter : String(id),
                                    "sort_by" : "vote_average.desc",
                                    "vote_count.gte": "100",
                                   ])
    }
}

extension NestedTV {

    static func genre(id: Int) -> NestedTV {
        return NestedTV(filter: "with_genres", id: id)
    }

    static func keyword(id: Int) -> NestedTV {
        return NestedTV(filter: "with_keywords", id: id)
    }

    static func productionCompany(id: Int) -> NestedTV {
        return NestedTV(filter: "with_companies", id: id)
    }

    static func network(id: Int) -> NestedTV {
        return NestedTV(filter: "with_networks", id: id)
    }

}
