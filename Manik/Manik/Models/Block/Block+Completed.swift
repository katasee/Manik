import Foundation

extension Block {
    func isCompleted(now: Date) -> Bool {
        guard status == .confirmed, let endsAt else { return false }

        return endsAt <= now
    }
}
