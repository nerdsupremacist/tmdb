
import Foundation
import GraphZahl

class DetailedEpisode: GraphQLObject {
    @Inline
    var episode: BasicEpisode

    @Inline
    var data: DetailedEpisodeData

    init(data: DetailedEpisodeData, showName: String, showId: Int) {
        self.episode = BasicEpisode(data: data, showName: showName, showId: showId)
        self.data = data
    }
}
