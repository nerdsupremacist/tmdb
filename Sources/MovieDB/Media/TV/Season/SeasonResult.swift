
import Foundation
import GraphZahl

class SeasonResult: GraphQLObject {
    @Inline
    var season: BasicSeason

    @Inline
    var data: SeasonResultData

    init(data: SeasonResultData, showName: String, showId: Int) {
        self.season = BasicSeason(data: data, showName: showName, showId: showId)
        self.data = data
    }
}
