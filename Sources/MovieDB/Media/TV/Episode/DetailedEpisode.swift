
import Foundation
import GraphZahl

class DetailedEpisode: GraphQLObject {
    @Inline
    var episode: Episode

    @Inline
    var data: DetailedEpisodeData

    init(data: DetailedEpisodeData, showName: String, showId: Int) {
        self.episode = Episode(data: data, showName: showName, showId: showId)
        self.data = data
    }
}
