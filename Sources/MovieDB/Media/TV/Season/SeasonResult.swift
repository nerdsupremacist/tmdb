
import Foundation
import GraphZahl

class SeasonResult: GraphQLObject {
    @Inline
    var season: Season

    @Inline
    var data: SeasonResultData

    init(data: SeasonResultData, showName: String, showId: Int) {
        self.season = Season(data: data, showName: showName, showId: showId)
        self.data = data
    }
}
