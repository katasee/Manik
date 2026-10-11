import Foundation

extension Sequence where Element == Client {
    func sortedNewestFirst() -> [Client] {
        sorted { $0.createdAt > $1.createdAt }
    }
}
