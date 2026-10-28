import Foundation

extension PlanEvent {
    func isPast(now: Date) -> Bool {
        guard let endsAt = DateFormat.dateTime.date(from: "\(date) \(endTime)") else { return false }

        return endsAt <= now
    }
}
