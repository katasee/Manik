import Foundation

extension Block {
    static func chronologically(_ lhs: Block, _ rhs: Block) -> Bool {
        if lhs.date != rhs.date { return lhs.date < rhs.date }
        if lhs.startMinutes != rhs.startMinutes { return lhs.startMinutes < rhs.startMinutes }

        return (lhs.id ?? "") < (rhs.id ?? "")
    }
}
