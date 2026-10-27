import Foundation

enum ConflictSubject {
    case window
    case plan
}

struct ConflictEntry: Identifiable, Equatable {
    let id: String
    let text: String
}

extension ConflictEntry {
    init(_ conflict: WindowConflict, subject: ConflictSubject) {
        let window = conflict.window
        let plan = conflict.plan
        let day = DateFormat.date
            .date(from: window.date)
            .map(DateFormat.dayMonthNumeric.string(from:)) ?? window.date
        let time = DateFormat.displayTime(window.time)
        let planTitle = "\(plan.emoji) \(plan.name)"
        let planStart = DateFormat.displayTime(plan.startTime)

        id = "\(window.date)_\(window.time)_\(plan.id ?? plan.startTime)"

        switch (subject, conflict.level, window.isBooked) {
        case (.window, .overlap, _):
            text = String(localized: "schedule.conflict.overlapLine \(day) \(time) \(planTitle)")
        case (.window, .near, _):
            text = String(localized: "schedule.conflict.nearLine \(day) \(time) \(planTitle) \(planStart)")
        case (.plan, .overlap, false):
            text = String(localized: "schedule.conflict.windowLine \(day) \(time)")
        case (.plan, .overlap, true):
            text = String(localized: "schedule.conflict.bookingLine \(day) \(time)")
        case (.plan, .near, false):
            text = String(localized: "schedule.conflict.nearWindowLine \(day) \(time)")
        case (.plan, .near, true):
            text = String(localized: "schedule.conflict.nearBookingLine \(day) \(time)")
        }
    }
}

enum ConflictNotice: Equatable {
    case overlap(ConflictEntry)
    case near([ConflictEntry])

    init?(_ conflicts: [WindowConflict], subject: ConflictSubject) {
        if let overlap = conflicts.first(where: { $0.level == .overlap }) {
            self = .overlap(ConflictEntry(overlap, subject: subject))
        } else if conflicts.isEmpty == false {
            self = .near(conflicts.map { ConflictEntry($0, subject: subject) })
        } else {
            return nil
        }
    }

    var level: PlanConflict {
        switch self {
        case .overlap: .overlap
        case .near: .near
        }
    }

    var blocksConfirm: Bool {
        level == .overlap
    }

    var mark: ConflictMark {
        ConflictMark(level)
    }
}
