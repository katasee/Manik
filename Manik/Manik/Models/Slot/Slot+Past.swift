import Foundation

extension Slot {
    func isPast(now: Date) -> Bool {
        guard let startsAt else { return false }

        return startsAt <= now
    }
}
