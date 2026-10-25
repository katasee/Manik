import Foundation

enum PlanTimeField {
    case start
    case end
}

struct PlanTimes {
    var start: ClockTime {
        didSet { keepEndAfterStart() }
    }

    var end: ClockTime
    var editing = PlanTimeField.start

    init() {
        self.init(start: WorkHours.defaultPlanStart, end: Self.defaultEnd(after: WorkHours.defaultPlanStart))
    }

    init(startTime: String, endTime: String) {
        guard
            let start = DateFormat.minutesOfDay(startTime),
            let end = DateFormat.minutesOfDay(endTime)
        else {
            self.init()
            return
        }

        self.init(start: ClockTime(minutesOfDay: start), end: ClockTime(minutesOfDay: end))
    }

    private init(start: ClockTime, end: ClockTime) {
        self.start = start
        self.end = end
    }

    var isValid: Bool {
        end.minutesOfDay > start.minutesOfDay
    }

    var startTime: String {
        DateFormat.storageTime(minutesOfDay: start.minutesOfDay)
    }

    var endTime: String {
        DateFormat.storageTime(minutesOfDay: end.minutesOfDay)
    }

    var startText: String {
        DateFormat.displayTime(startTime)
    }

    var endText: String {
        DateFormat.displayTime(endTime)
    }

    private mutating func keepEndAfterStart() {
        guard end.minutesOfDay <= start.minutesOfDay else { return }

        end = Self.defaultEnd(after: start)
    }

    private static func defaultEnd(after start: ClockTime) -> ClockTime {
        ClockTime(
            minutesOfDay: min(
                start.minutesOfDay + WorkHours.defaultPlanMinutes,
                WorkHours.latestTime.minutesOfDay
            )
        )
    }
}
