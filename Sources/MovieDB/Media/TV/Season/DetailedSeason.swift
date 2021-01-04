
import Foundation
import GraphZahl

class DetailedSeason: GraphQLObject {
    @Inline
    var season: Season

    @Ignore
    var data: DetailedSeasonData

    var episodes: [Episode] {
        return data.episodes.map { Episode(data: $0, showName: season.showName, showId: season.showId) }
    }

    init(data: DetailedSeasonData, showName: String, showId: Int) {
        self.season = Season(data: data, showName: showName, showId: showId)
        self.data = data
    }
}
