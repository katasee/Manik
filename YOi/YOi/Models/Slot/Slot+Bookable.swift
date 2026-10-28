import Foundation

extension Slot {
    func isBookable(now: Date) -> Bool {
        isBooked == false && isPast(now: now) == false
    }
}
