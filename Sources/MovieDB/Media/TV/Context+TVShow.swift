
import Foundation
import ContextKit

extension Context.Key where T == TVShow {
    static let show = Context.Key<TVShow>()
}

extension ContextKeyPaths {

    var show: Context.Key<TVShow> {
        return .show
    }

}
