import Foundation

struct ConflictEntry: Identifiable, Equatable {
    let id: String
    let text: String
}

extension ConflictEntry {
    init(_ conflict: WindowConflict) {
        let window = conflict.window
        let plan = conflict.plan
        let day = DateFormat.date
            .date(from: window.date)
            .map(DateFormat.dayMonthNumeric.string(from:)) ?? window.date
        let time = DateFormat.displayTime(window.time)
        let planTitle = "\(plan.emoji) \(plan.name)"

        id = "\(window.date)_\(window.time)_\(plan.id ?? plan.startTime)"

        switch conflict.level {
        case .overlap:
            text = String(localized: "schedule.conflict.overlapLine \(day) \(time) \(planTitle)")
        case .near:
            let planStart = DateFormat.displayTime(plan.startTime)

            text = String(localized: "schedule.conflict.nearLine \(day) \(time) \(planTitle) \(planStart)")
        }
    }
}

enum ConflictNotice: Equatable {
    case overlap(ConflictEntry)
    case near([ConflictEntry])

    init?(_ conflicts: [WindowConflict]) {
        if let overlap = conflicts.first(where: { $0.level == .overlap }) {
            self = .overlap(ConflictEntry(overlap))
        } else if conflicts.isEmpty == false {
            self = .near(conflicts.map(ConflictEntry.init))
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
