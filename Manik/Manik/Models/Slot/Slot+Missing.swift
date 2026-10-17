import Foundation

extension Slot {
    static func missing(
        days: Set<String>,
        times: Set<String>,
        existingIds: Set<String>,
        now: Date
    ) -> [Slot] {
        days
            .flatMap { day in times.map { Slot(date: day, time: $0) } }
            .filter { existingIds.contains(documentId(date: $0.date, time: $0.time)) == false }
            .filter { $0.isPast(now: now) == false }
            .sorted(by: chronologically)
    }
}
