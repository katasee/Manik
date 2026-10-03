import Foundation

extension Block {
    func isUpcoming(now: Date) -> Bool {
        guard let startsAt else { return false }

        return startsAt > now
    }
}
