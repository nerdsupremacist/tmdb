
import Foundation
import GraphZahl

class DetailedSeason: GraphQLObject {
    @Inline
    var season: BasicSeason

    @Ignore
    var data: DetailedSeasonData

    var episodeCount: Int {
        return data.episodes.count
    }

    init(data: DetailedSeasonData, showName: String, showId: Int) {
        self.season = BasicSeason(data: data, showName: showName, showId: showId)
        self.data = data
    }

    func episodes(viewerContext: MovieDB.ViewerContext) -> [Episode] {
        return data.episodes.map { Episode(episode: BasicEpisode(data: $0, showName: season.showName, showId: season.showId), viewerContext: viewerContext) }
    }
}
