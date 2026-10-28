import Foundation

extension Slot {
    static func chronologically(_ lhs: Slot, _ rhs: Slot) -> Bool {
        if lhs.date != rhs.date { return lhs.date < rhs.date }
        if lhs.time != rhs.time { return lhs.time < rhs.time }

        return (lhs.id ?? "") < (rhs.id ?? "")
    }
}
