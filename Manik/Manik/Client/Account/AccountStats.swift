import Foundation

struct AccountStats {
    let visitCount: Int
    let favoriteServiceName: String?

    static let empty = AccountStats(visitCount: 0, favoriteServiceName: nil)
}
