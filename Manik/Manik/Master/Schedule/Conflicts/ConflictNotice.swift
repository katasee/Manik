struct ConflictEntry: Identifiable, Equatable {
    let id: String
    let text: String
}

enum ConflictNotice: Equatable {
    case overlap(ConflictEntry)
    case near([ConflictEntry])

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
